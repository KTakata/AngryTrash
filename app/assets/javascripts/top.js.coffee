$ ->
  #表示される画像のサイズは固定する
  #TODO:ゴミとゴミ箱両方同じ変数を使いたいので変数名を変更する。
  window.BLOCK_WIDTH = 60
  window.BLOCK_HEIGHT = 60
  $("#canvas").dblclick (e) ->
    if e.target.id == "canvas"
      [x, y] = position(e)
      createBlock(x, y)

 # jquery)draggableを書くと自動で"position:relative"が付与されるため（省略値）
 # "position:absolute"を指定する
  $('#canvas img').draggable(containment: "parent").css(position: "absolute")

  $(document).on "dragstop", "#canvas img", (e) ->
    # Move block
    if e.target.alt == "block"
      block = $(e.target)
      blockId = block.data("blockId")
      trash = $('#canvas img[alt="trash"]')
      discardDecision(block, blockId, trash)
    # Move trash box
    else if e.target.alt == "trash"
      trash = $(e.target)
      trashId = trash.data("trashId")
      x = trash.position().left
      y = trash.position().top
      $.ajax "/trashs/#{trashId}", type: "PUT", data: { trash: { x: x, y: y } }

# Create block button
$ ->
  $("#block_create_btn").click ->
    createBlock(0, 0, $("#canvas"))

#change canvas size
window.set_canvas_size = (form) ->
  canvas_width = parseInt(form.size_w.value, 10)
  canvas_height = parseInt(form.size_h.value, 10)
  trash = $('#canvas img[alt="trash"]')
  if form.size_w.value.match(/[0-9]$/) and form.size_h.value.match(/[0-9]$/)
    checkCanvasSize(trash, canvas_width, canvas_height)
    checkTrashPosition(trash, canvas_width, canvas_height)
    deleteAllBlocks()
  else
    alert("please insert Byte numeric characters")

createBlock = (x, y) ->
  maxWidth = canvas.offsetWidth - BLOCK_WIDTH
  maxHeight = canvas.offsetHeight - BLOCK_HEIGHT
  x = Math.min(x, maxWidth)
  y = Math.min(y, maxHeight)
  overlapFlag = checkOverlapBlocks(x, y)
  if overlapFlag == false
    $.post '/blocks', block: { x: x, y: y }, (block_id) ->
      block = $('<img alt="block"/>').
        attr("src", "assets/kanzume.png").
        css(left: "#{x}px", top: "#{y}px", width: "#{BLOCK_WIDTH}px", height: "#{BLOCK_HEIGHT}px").
        data("blockId", block_id).
        draggable(containment: "parent").
        css(position: "absolute")
      $('#canvas').append(block)
      $('#block_count p').text("残りゴミの数:#{$('#canvas img[alt="block"][class="ui-draggable"]').length}個");

position = (e) ->
  pos = $(e.target).position()
  x = e.pageX - pos.left
  y = e.pageY - pos.top
  [x, y]

discardDecision = (block, blockId, trash) ->
  block_left = block.position().left
  block_top = block.position().top
  block_width = block.width() + block_left
  block_height = block.height() + block_top
  trash_left = trash.position().left
  trash_top = trash.position().top
  trash_width = trash.width() + trash_left
  trash_height = trash.height() + trash_top

  count = 0
  blockEscapeCount = 0
  escapeFlag = false
  while count < $('#canvas img[alt="block"][class="ui-draggable"]').length
    still_block_left = parseInt($('#canvas img[alt="block"][class="ui-draggable"]')[count].style.left, 10)
    still_block_top = parseInt($('#canvas img[alt="block"][class="ui-draggable"]')[count].style.top, 10)
    still_block_width = still_block_left + window.BLOCK_WIDTH
    still_block_height = still_block_top + window.BLOCK_HEIGHT
    check_overlap_block = checkOverlaps(block_left, block_top, still_block_left, still_block_top)
    if check_overlap_block == true
      [block_left, block_top] = moveAction(check_overlap_block, block_left, block_top, block)
      block_width = block.width() + block_left
      block_height = block.height() + block_top
      count = 0
      blockEscapeCount =  blockEscapeCount + 1
      if blockEscapeCount > 4
        escapeFlag = escapeBlock(block, blockId, block_left, block_top)
        break
    else
      count = count + 1
  check_in_trash = checkOverlaps(block_left, block_top, trash_left, trash_top)
  if check_in_trash == true
    block.hide "slow", ->
      block.remove()
    $.ajax "/blocks/#{blockId}", type: "DELETE", data: { block: { x: block_left, y: block_top } }
    $('#block_count p').text("残りゴミの数:#{$('#canvas img[alt="block"][class="ui-draggable"]').length}個");
  else if escapeFlag == false
    $.ajax "/blocks/#{blockId}", type: "PUT", data: { block: { x: block_left, y: block_top } }

checkCanvasSize = (trash, canvas_width, canvas_height) ->
  if canvas_width < trash.width() or canvas_height < trash.height()
    alert("canvas size is too small!")
  else
    $("#canvas").css(width: "#{canvas_width}px", height: "#{canvas_height}px")
    $.ajax "/canvases", type: "PUT", data: { canvas: { w: canvas_width, h: canvas_height }}

checkTrashPosition = (trash, canvas_width, canvas_height) ->
  if trash.position().left + trash.width() < canvas_width and trash.position().top + trash.height() < canvas_height
    return
  else
    trash_left = canvas_width - trash.width()
    trash_top = canvas_height - trash.height()
    trashId = trash.data("trashId")
    $.ajax "/trashs/#{trashId}", type: "PUT", data: { trash: { x: trash_left, y: trash_top } }
    $('#canvas img[alt="trash"]').animate({
      left: "#{trash_left}px",
      top: "#{trash_top}px"
    }, "fast" );

deleteAllBlocks = () ->
  $.ajax "/blocks/destory_all", type: "GET"
  $('#canvas img[alt="block"]').remove()
  $('#block_count p').text("残りゴミの数:#{$('#canvas img[alt="block"][class="ui-draggable"]').length}個");

checkOverlapBlocks = (new_left, new_top) ->
  if $('#canvas img[alt="block"]').length > 0
    count = 0
    while count < $('#canvas img[alt="block"]').length
      already_left = parseInt($('#canvas img[alt="block"]')[count].style.left, 10)
      already_top = parseInt($('#canvas img[alt="block"]')[count].style.top, 10)
      already_width = already_left + window.BLOCK_WIDTH
      already_height = already_top + window.BLOCK_HEIGHT
      if checkOverlaps(new_left, new_top, already_left, already_top)
        return(true)
      count = count + 1
  return(false)

checkOverlaps = (x1,y1,x2,y2) ->
  #前提：ゴミ箱とゴミの大きさは同じ
  if (x1 < (x2 + window.BLOCK_WIDTH)) and (x2 < (x1 + window.BLOCK_WIDTH)) and (y1 < (y2 + window.BLOCK_HEIGHT)) and (y2 < (y1 + window.BLOCK_HEIGHT))
    return true
  else
    return false

moveAction = (check_overlap_block, block_left, block_top, block) ->
  if $("#canvas").width() - block_left - window.BLOCK_WIDTH > window.BLOCK_WIDTH * 2
    move_left = block_left + (window.BLOCK_WIDTH * 2)
  else
    move_left = block_left - (window.BLOCK_WIDTH * 2)
  if $("#canvas").height() - block_top - window.BLOCK_HEIGHT > window.BLOCK_HEIGHT * 2
    move_top = block_top + (window.BLOCK_HEIGHT * 2)
  else
    move_top = block_top - (window.BLOCK_HEIGHT * 2)
  block.animate({ 
    left: "#{move_left}px",
    top: "#{move_top}px"
  }, "fast" );
  block_left = move_left
  block_top = move_top
  [block_left,block_top]

escapeBlock = (block, blockId, left, top) ->
  block.animate({
    left: "#{$('#canvas img[alt="trash"]').position().left}px"
    top: "#{$('#canvas img[alt="trash"]').position().top}px"
  }, "slow");
  block.hide "slow", ->
    block.remove()
  $.ajax "/blocks/#{blockId}", type: "DELETE", data: { block: { x: left, y: top } }
  $('#block_count p').text("残りゴミの数:#{$('#canvas img[alt="block"][class="ui-draggable"]').length}個");
  return true
