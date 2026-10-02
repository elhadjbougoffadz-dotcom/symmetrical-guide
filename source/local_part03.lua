    focusAndShowKeyboard(searchEdit)
    isKeyboardShown = true
  end
  searchEdit.addTextChangedListener(TextWatcher({
    onTextChanged = function(s)
      local query = tostring(s):lower()
      local sourceData = (searchMode == "titles") and t1 or t2
      currentList = {}
      for _, v in ipairs(sourceData) do
        if tostring(v):lower():find(query) then
          table.insert(currentList, v)
        end
      end
      refreshListAdapterPreservePosition(_G.list, getStyledAdapter(currentList))
      updateMainDialogPosition(scj, currentList)
      updateDialogHeightDynamic(scj, #currentList, 0.95, 1)
      if query ~= "" then
        if #currentList > 0 then
          btnNoResult.setVisibility(View.GONE)
          speakDelayed(tostring(#currentList))
        else
          btnNoResult.setVisibility(View.VISIBLE)
          speakDelayed(L("noResult"))
        end
      else
        btnNoResult.setVisibility(View.GONE)
      end
    end
  }))
  local function openContentDialog(titleText)
    playSafeTone(ToneGenerator.TONE_PROP_PROMPT, 150)
    local dlgC = LuaDialog(service)
    local layoutC = {
      LinearLayout,
      orientation = "vertical",
      padding = "0dp",
      backgroundColor = BLUE_BG,
      {
        TextView,
        text = L("addContentTitle"),
        textColor = TEXT_COLOR,
        textSize = responsiveSp(L("addContentTitle"), 35, 24, 16),
        singleLine = true,
        ellipsize = "end",
        backgroundColor = DARK_BLUE_TITLE,
        gravity = "center",
        textAlignment = "center",
        layout_width = "match_parent",
        layout_height = "wrap_content",
        padding = "10dp",
        typeface = Typeface.DEFAULT
      },
      {
        EditText,
        id = "edContentInput",
        hint = L("contentHint"),
        textColor = TEXT_COLOR,
        hintTextColor = 0xAAFFFFFF,
        textSize = "20sp",
        layout_height = math.floor(service.getResources().getDisplayMetrics().heightPixels * 0.40),
        layout_width = "match_parent",
        backgroundColor = BLUE_BG,
        gravity = "center",
        textAlignment = "center",
        singleLine = false,
        maxLines = 20
      },
      {
        LinearLayout,
        orientation = "horizontal",
        backgroundColor = BLUE_BG,
        layout_width = "match_parent",
        layout_height = "wrap_content",
        layout_marginTop = "4dp",
        layout_marginBottom = "4dp",
        {
          Button,
          id = "btnClipC",
          text = L("clipboard"),
          textColor = TEXT_COLOR,
          textSize = "15sp",
          backgroundColor = SOFT_GREEN,
          layout_width = "0dp",
          layout_height = "wrap_content",
          layout_weight = "1",
          layout_marginRight = "2dp"
        },
        {
          Button,
          id = "btnFavC",
          text = L("favorites"),
          textColor = TEXT_COLOR,
          textSize = "15sp",
          backgroundColor = SOFT_GREEN,
          layout_width = "0dp",
          layout_height = "wrap_content",
          layout_weight = "1",
          layout_marginRight = "2dp"
        },
        {
          Button,
          id = "btnDeviceClipC",
          text = L("deviceClipboardTitle"),
          textColor = TEXT_COLOR,
          textSize = "15sp",
          backgroundColor = SOFT_GREEN,
          layout_width = "0dp",
          layout_height = "wrap_content",
          layout_weight = "1",
          layout_marginRight = "2dp"
        },
        {
          Button,
          id = "btnDoneC",
          text = L("done"),
          textColor = TEXT_COLOR,
          textSize = "15sp",
          backgroundColor = GREEN_BG,
          layout_width = "0dp",
          layout_height = "wrap_content",
          layout_weight = "1",
          layout_marginRight = "2dp"
        },
        {
          Button,
          id = "btnCancelC",
          text = L("cancel"),
          textColor = TEXT_COLOR,
          textSize = "15sp",
          backgroundColor = BUTTON_BLUE,
          layout_width = "0dp",
          layout_height = "wrap_content",
          layout_weight = "1"
        }
      }
    }
    dlgC.View = loadlayout(layoutC)
    _G.btnClipC.onClick = function() showClipboardPicker(_G.edContentInput) end
    _G.btnFavC.onClick = function() showFavoritesPicker(_G.edContentInput) end
    _G.btnDeviceClipC.onClick = function() showDeviceClipboardPicker(_G.edContentInput) end
    _G.btnDoneC.onClick = function()
      local contentText = tostring(_G.edContentInput.getText() or "")
      if contentText:gsub("%s+", "") == "" then
        playSafeTone(ToneGenerator.TONE_CDMA_LOW_PBX_L, 150)
        speakDelayed(L("emptyContentMsg"))
        return
      end
      playSafeTone(ToneGenerator.TONE_PROP_ACK, 150)
      table.insert(t1, titleText)
      table.insert(t2, contentText)
      f1:write(t1)
      f2:write(t2)
      currentList = (searchMode == "titles") and t1 or t2
      refreshMemoView(scj, currentList)
      dlgC.dismiss()
      speakDelayed(L("addSuccess"))
    end
    _G.btnCancelC.onClick = function()
      dlgC.dismiss()
      if scj then scj.show() end
    end
    dlgC.show()
    focusAndShowKeyboard(_G.edContentInput)
    pcall(function()
      local window = dlgC.getWindow()
      if window then
        window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE)
      end
    end)
  end
  _G.btnBottomAdd.onClick = function()
    playSafeTone(ToneGenerator.TONE_CDMA_KEYPAD_VOLUME_KEY_LITE, 120)
    local dlgT = LuaDialog(service)
    local layoutT = {
      LinearLayout,
      orientation = "vertical",
      backgroundColor = BLUE_BG,
      layout_width = "match_parent",
      layout_height = "wrap_content",
      padding = "0dp",
      {
        TextView,
        text = L("addTitleTitle"),
        textColor = TEXT_COLOR,
        textSize = responsiveSp(L("addTitleTitle"), 35, 24, 16),
        singleLine = true,
        ellipsize = "end",
        backgroundColor = DARK_BLUE_TITLE,
        gravity = "center",
        layout_width = "match_parent",
        layout_height = "wrap_content",
        padding = "10dp",
        typeface = Typeface.DEFAULT
      },
      {
        EditText,
        id = "edTitle",
        hint = L("titleHint"),
        textColor = TEXT_COLOR,
        hintTextColor = 0xAAFFFFFF,
        textSize = "20sp",
        backgroundColor = BLUE_BG,
        layout_width = "match_parent",
        layout_height = "wrap_content",
        layout_marginTop = "8dp",
        layout_marginBottom = "8dp",
        gravity = "center",
        textAlignment = "center",
        singleLine = false,
        maxLines = 20
      },
      {
        LinearLayout,
        orientation = "horizontal",
        backgroundColor = BLUE_BG,
        layout_width = "match_parent",
        layout_height = "wrap_content",
        layout_marginBottom = "4dp",
        {
          Button,
          id = "btnClipT",
          text = L("clipboard"),
          textColor = TEXT_COLOR,
          textSize = "15sp",
          backgroundColor = SOFT_GREEN,
          layout_width = "0dp",
          layout_height = "wrap_content",
          layout_weight = "1",
          layout_marginRight = "2dp"
        },
        {
          Button,
          id = "btnFavT",
          text = L("favorites"),
          textColor = TEXT_COLOR,
          textSize = "15sp",
          backgroundColor = SOFT_GREEN,
          layout_width = "0dp",
          layout_height = "wrap_content",
          layout_weight = "1",
          layout_marginRight = "2dp"
        },
        {
          Button,
          id = "btnDeviceClipT",
          text = L("deviceClipboardTitle"),
          textColor = TEXT_COLOR,
          textSize = "15sp",
          backgroundColor = SOFT_GREEN,
          layout_width = "0dp",
          layout_height = "wrap_content",
          layout_weight = "1",
          layout_marginRight = "2dp"
        },
        {
          Button,
          id = "btnNextT",
          text = L("next"),
          textColor = TEXT_COLOR,
          textSize = "15sp",
          backgroundColor = GREEN_BG,
          layout_width = "0dp",
          layout_height = "wrap_content",
          layout_weight = "1",
          layout_marginRight = "2dp"
        },
        {
          Button,
          id = "btnCancelT",
          text = L("cancel"),
          textColor = TEXT_COLOR,
          textSize = "15sp",
          backgroundColor = BUTTON_BLUE,
          layout_width = "0dp",
          layout_height = "wrap_content",
          layout_weight = "1"
        }
      }
    }
    dlgT.View = loadlayout(layoutT)
    setupTitleLimiter(_G.edTitle)
    _G.btnClipT.onClick = function() showClipboardPicker(_G.edTitle) end
    _G.btnFavT.onClick = function() showFavoritesPicker(_G.edTitle) end
    _G.btnDeviceClipT.onClick = function() showDeviceClipboardPicker(_G.edTitle) end
    _G.btnNextT.onClick = function()
      local tTitle = tostring(_G.edTitle.getText() or "")
      if tTitle:gsub("%s+", "") == "" then
        speakDelayed(L("emptyTitleMsg"))
        return
      end
      dlgT.dismiss()
      openContentDialog(tTitle)
    end
    _G.btnCancelT.onClick = function()
      dlgT.dismiss()
      if scj then scj.show() end
    end
    dlgT.show()
    pcall(function()
      local window = dlgT.getWindow()
      if window then
        local dm = service.getResources().getDisplayMetrics()
        window.setGravity(Gravity.CENTER)
        window.setLayout(math.floor(dm.widthPixels * 0.95), WindowManager.LayoutParams.WRAP_CONTENT)
        window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE)
      end
    end)
    focusAndShowKeyboard(_G.edTitle)
  end
  local list = _G.list
  refreshListAdapterPreservePosition(list, getStyledAdapter(currentList))
  updateInterfaceTexts()
  updateEmptyMemoState(currentList)
  applyMainDialogConstraints(scj, hasMemoItems(currentList))
  updateDialogHeightDynamic(scj, #currentList, 0.95, 1)
  list.onItemClick = function(l, v, p, i)
    playSafeTone(ToneGenerator.TONE_CDMA_KEYPAD_VOLUME_KEY_LITE, 100)
    local yd = _G.yd
    local clickedVal = currentList[p + 1]
    local realIndex = 1
    local sourceData = (searchMode == "titles") and t1 or t2
    for idx, val in ipairs(sourceData) do
      if val == clickedVal then realIndex = idx break end
    end
    if yd then
      speakDelayed(L("movedFirst"))
      table.remove(t1, yd)
      table.insert(t1, realIndex, _G.o)
      table.remove(t2, yd)
      table.insert(t2, realIndex, _G.o2)
      _G.yd = nil
      currentList = (searchMode == "titles") and t1 or t2
      f1:write(t1)
      f2:write(t2)
      refreshMemoView(scj, currentList)
    else
      local itemTitle = t1[realIndex] or ""
      local itemContent = t2[realIndex] or ""
      local dlgAction = LuaDialog(service)
      local actionLayout = {
        LinearLayout,
        orientation = "vertical",
        backgroundColor = BLUE_BG,
        layout_width = "match_parent",
        layout_height = "wrap_content",
        padding = "0dp",
        {
          TextView,
          text = L("actionTitle"),
          textColor = TEXT_COLOR,
          textSize = responsiveSp(L("actionTitle"), 35, 24, 16),
          singleLine = true,
          ellipsize = "end",
          backgroundColor = DARK_BLUE_TITLE,
          gravity = "center",
          padding = "10dp",
          typeface = Typeface.DEFAULT,
          layout_width = "match_parent",
          layout_height = "wrap_content"
        },
        {
          LinearLayout,
          orientation = "horizontal",
          backgroundColor = BLUE_BG,
          layout_width = "match_parent",
          layout_height = "wrap_content",
          layout_marginTop = "10dp",
          {
            Button,
            id = "btnActionCopy",
            text = L("copy"),
            textColor = TEXT_COLOR,
            textSize = "14.28sp",
            backgroundColor = GREEN_BG,
            layout_width = "0dp",
            layout_height = "wrap_content",
            layout_weight = "1",
            layout_marginRight = "2dp"
          },
          {
            Button,
            id = "btnActionPaste",
            text = L("paste"),
            textColor = TEXT_COLOR,
            textSize = "14.28sp",
            backgroundColor = GREEN_BG,
            layout_width = "0dp",
            layout_height = "wrap_content",
            layout_weight = "1",
            layout_marginRight = "2dp"
          },
          {
            Button,
            id = "btnActionPrint",
            text = L("print"),
            contentDescription = L("print"),
            textColor = TEXT_COLOR,
            textSize = "14.28sp",
            backgroundColor = GREEN_BG,
            layout_width = "0dp",
            layout_height = "wrap_content",
            layout_weight = "1",
            layout_marginRight = "2dp"
          },
          {
            Button,
            id = "btnActionCancel",
            text = L("cancel"),
            textColor = TEXT_COLOR,
            textSize = "14.28sp",
            backgroundColor = BUTTON_BLUE,
            layout_width = "0dp",
            layout_height = "wrap_content",
            layout_weight = "1"
          }
        }
      }

      dlgAction.View = loadlayout(actionLayout)

      _G.btnActionCopy.onClick = function()
        dlgAction.dismiss()
        service.copy(itemContent ~= "" and itemContent or itemTitle)
        speakDelayed(L("copied"))
      end

      _G.btnActionPaste.onClick = function()
        dlgAction.dismiss()
        if scj then scj.dismiss() end
        task(200, function() service.paste(itemContent) end)
      end

      local function openPrintDialog()
        dlgAction.dismiss()

        local dlgPrint = LuaDialog(service)
        local printLayout = {
          LinearLayout,
          orientation = "vertical",
          backgroundColor = BLUE_BG,
          layout_width = "match_parent",
          layout_height = "wrap_content",
          padding = "0dp",
          {
            TextView,
            text = L("actionTitle"),
            textColor = TEXT_COLOR,
            textSize = responsiveSp(L("actionTitle"), 35, 24, 16),
            singleLine = true,
            ellipsize = "end",
            backgroundColor = DARK_BLUE_TITLE,
            gravity = "center",
            padding = "10dp",
            typeface = Typeface.DEFAULT,
            layout_width = "match_parent",
            layout_height = "wrap_content"
          },
          {
            ScrollView,
            id = "scrollPrintFrame",
            layout_width = "match_parent",
            layout_height = "0dp",
            layout_weight = "1",
            layout_gravity = "center",
            fillViewport = true,
            backgroundColor = DARK_BLUE_TITLE,
            layout_marginTop = "10dp",
            layout_marginBottom = "5dp",
            layout_marginLeft = "10dp",
            layout_marginRight = "10dp",
            {
              LinearLayout,
              id = "printContentContainer",
              orientation = "vertical",
              backgroundColor = DARK_BLUE_TITLE,
              gravity = "center",
              padding = "12dp",
              layout_width = "match_parent",
              layout_height = "wrap_content"
            }
          },
          {
            LinearLayout,
            orientation = "horizontal",
            backgroundColor = BLUE_BG,
            layout_width = "match_parent",
            layout_height = "wrap_content",
            layout_marginTop = "10dp",
            {
              Button,
              id = "btnPrintCopy",
              text = L("copy"),
              textColor = TEXT_COLOR,
              textSize = "14.28sp",
              backgroundColor = GREEN_BG,
              layout_width = "0dp",
              layout_height = "wrap_content",
              layout_weight = "1",
              layout_marginRight = "2dp"
            },
            {
              Button,
              id = "btnPrintPaste",
              text = L("paste"),
              textColor = TEXT_COLOR,
              textSize = "14.28sp",
              backgroundColor = GREEN_BG,
              layout_width = "0dp",
              layout_height = "wrap_content",
              layout_weight = "1",
              layout_marginRight = "2dp"
            },
            {
              Button,
              id = "btnPrintMode",
              text = L("printSplitLines"),
              contentDescription = L("printSplitLines"),
              textColor = TEXT_COLOR,
              textSize = "14.28sp",
              backgroundColor = GREEN_BG,
              layout_width = "0dp",
              layout_height = "wrap_content",
              layout_weight = "1",
              layout_marginRight = "2dp"
            },
            {
              Button,
              id = "btnPrintCancel",
              text = L("cancel"),
              textColor = TEXT_COLOR,
              textSize = "14.28sp",
              backgroundColor = BUTTON_BLUE,
              layout_width = "0dp",
              layout_height = "wrap_content",
              layout_weight = "1"
            }
          }
        }

        dlgPrint.View = loadlayout(printLayout)

        local printTextWrapped = true
        local originalPrintText = itemContent ~= "" and itemContent or itemTitle

        local function createPrintTextView(textValue)
          local tv = TextView(service)
          tv.setText(tostring(textValue or ""))
          tv.setTextColor(TEXT_COLOR)
          tv.setTextSize(20)
          tv.setBackgroundColor(DARK_BLUE_TITLE)
          tv.setGravity(Gravity.CENTER)
          tv.setTextAlignment(View.TEXT_ALIGNMENT_CENTER)
          tv.setSingleLine(false)
          tv.setPadding(12, 12, 12, 12)
          tv.setLayoutParams(LinearLayout.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.WRAP_CONTENT
          ))
          tv.setContentDescription(tostring(textValue or ""))
          tv.setFocusable(true)
          tv.setImportantForAccessibility(View.IMPORTANT_FOR_ACCESSIBILITY_YES)
          return tv
        end

        local function renderWholeText(textValue)
          _G.printContentContainer.removeAllViews()
          _G.printContentContainer.addView(createPrintTextView(textValue))
          _G.scrollPrintFrame.setVisibility(View.VISIBLE)
        end

        local function renderEachLine(textValue)
          _G.printContentContainer.removeAllViews()
          local normalized = tostring(textValue or ""):gsub("\r\n", "\n"):gsub("\r", "\n")
          local hasLine = false
          for line in (normalized .. "\n"):gmatch("(.-)\n") do
            _G.printContentContainer.addView(createPrintTextView(line))
            hasLine = true
          end
          if not hasLine then
            _G.printContentContainer.addView(createPrintTextView(normalized))
          end
          _G.scrollPrintFrame.setVisibility(View.VISIBLE)
        end

        local function updatePrintFrame(displayText)
          pcall(function()
            local dm = service.getResources().getDisplayMetrics()
            local density = dm.density or 1
            local textSizePx = 20 * density
            local lineHeight = math.floor(textSizePx * 1.55)
            local sourceLines = 1
            local normalized = tostring(displayText or ""):gsub("\r\n", "\n"):gsub("\r", "\n")
            for _ in (normalized .. "\n"):gmatch("(.-)\n") do
              sourceLines = sourceLines + 1
            end
            sourceLines = math.max(1, sourceLines - 1)

            local minHeight = math.floor(110 * density)
            local maxHeight = math.floor(dm.heightPixels * 0.80)
            local desiredHeight = math.max(
              minHeight,
              math.min(maxHeight, sourceLines * lineHeight + math.floor(30 * density))
            )

            local lp = _G.scrollPrintFrame.getLayoutParams()
            lp.width = WindowManager.LayoutParams.MATCH_PARENT
            lp.height = desiredHeight
            lp.weight = 0
            _G.scrollPrintFrame.setLayoutParams(lp)

            local window = dlgPrint.getWindow()
            if window then
              window.setGravity(Gravity.CENTER)
              window.setLayout(
                WindowManager.LayoutParams.MATCH_PARENT,
                WindowManager.LayoutParams.WRAP_CONTENT
              )
            end
            _G.scrollPrintFrame.scrollTo(0, 0)
          end)
        end

        _G.btnPrintMode.onClick = function()
          playSafeTone(ToneGenerator.TONE_PROP_ACK, 80)
          if printTextWrapped then
            renderWholeText(originalPrintText)
            printTextWrapped = false
            _G.btnPrintMode.setText(L("printWholeText"))
            _G.btnPrintMode.setContentDescription(L("printWholeText"))
            updatePrintFrame(originalPrintText)
            task(120, function() speakDelayed(L("printWholeText")) end)
          else
            renderEachLine(originalPrintText)
            printTextWrapped = true
            _G.btnPrintMode.setText(L("printSplitLines"))
            _G.btnPrintMode.setContentDescription(L("printSplitLines"))
            updatePrintFrame(originalPrintText)
            task(120, function() speakDelayed(L("printSplitLines")) end)
          end
        end

        _G.btnPrintCopy.onClick = function()
          dlgPrint.dismiss()
          service.copy(originalPrintText)
          speakDelayed(L("copied"))
        end

        _G.btnPrintPaste.onClick = function()
          dlgPrint.dismiss()
          if scj then scj.dismiss() end
          task(200, function() service.paste(originalPrintText) end)
        end

        local function closePrintAndReturnToMemo()
          pcall(function() dlgPrint.dismiss() end)
          pcall(function() dlgAction.dismiss() end)
          return true
        end

        _G.btnPrintCancel.onClick = function()
          closePrintAndReturnToMemo()
        end

        dlgPrint.setOnKeyListener(function(dialog, keyCode, event)
          if keyCode == KeyEvent.KEYCODE_BACK and event.getAction() == KeyEvent.ACTION_UP then
            closePrintAndReturnToMemo()
            return true
          end
          return false
        end)

        dlgPrint.show()
        renderEachLine(originalPrintText)
        updatePrintFrame(originalPrintText)
      end

      _G.btnActionPrint.onClick = openPrintDialog
      _G.btnActionCancel.onClick = function() dlgAction.dismiss() end

      dlgAction.show()
    end
  end
  list.onItemLongClick = function(l, v, p, i)
    playSafeTone(ToneGenerator.TONE_SUP_CONGESTION_ABBREV, 200)
    local clickedVal = currentList[p + 1]
    local realIndex = 1
    local sourceData = (searchMode == "titles") and t1 or t2
    for idx, val in ipairs(sourceData) do
      if val == clickedVal then realIndex = idx break end
    end
    local dlg = LuaDialog(service)
    local menu_grid_item_layout = {
      LinearLayout,
      orientation = "horizontal",
      backgroundColor = BLUE_BG,
      layout_width = "match_parent",
      layout_height = "wrap_content",
      padding = "0dp",
      {
        LinearLayout,