          if not selectedMap[i] then
            allSelectedNow = false
            break
          end
        end
        _G.btnJieshuoSelectAll.setText(allSelectedNow and L("cancelSelectAll") or L("selectAll"))
      end
      if selectedMap[idx] then
        speakDelayed(L("selectedSpokenShort"))
      end
    end
      _G.btnJieshuoSelectAll.onClick = function()
      local allSelected = (#rawItems > 0)
      for i = 1, #rawItems do
        if not selectedMap[i] then allSelected = false break end
      end
      selectedMap = {}
      if not allSelected then
        for i = 1, #rawItems do selectedMap[i] = true end
      end
      rebuildDisplayData()
      pcall(function() impAdapter.notifyDataSetChanged() end)
      speakDelayed(allSelected and L("allDeselected") or L("allSelected"))
    end
    _G.btnImportAll.onClick = function()
      playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
      local addedCount = #rawItems
      for _, itemText in ipairs(rawItems) do
        local lines = {}
        for line in itemText:gmatch("([^\r\n]+)") do
          table.insert(lines, line)
        end
        local titleText = cleanAndFormatTitle(lines[1] or itemText)
        table.insert(t1, titleText)
        table.insert(t2, itemText)
      end
      f1:write(t1)
      f2:write(t2)
      dlgImp.dismiss()
      refreshMemoAfterImport()
      if parentDlg then
        pcall(function()
          if refreshManageAfterDataChange then
            refreshManageAfterDataChange()
          else
            parentDlg.show()
          end
        end)
      end
      speakDelayed(addedCount)
    end
    _G.btnImportSelected.onClick = function()
      playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
      local addedCount = 0
      for idx, itemText in ipairs(rawItems) do
        if selectedMap[idx] then
          local lines = {}
          for line in itemText:gmatch("([^\r\n]+)") do
            table.insert(lines, line)
          end
          local titleText = cleanAndFormatTitle(lines[1] or itemText)
          table.insert(t1, titleText)
          table.insert(t2, itemText)
          addedCount = addedCount + 1
        end
      end
      if addedCount == 0 then
        speakDelayed(L("selectItemsToDelete"))
        return
      end
      f1:write(t1)
      f2:write(t2)
      dlgImp.dismiss()
      refreshMemoAfterImport()
      if parentDlg then
        pcall(function()
          if refreshManageAfterDataChange then
            refreshManageAfterDataChange()
          else
            parentDlg.show()
          end
        end)
      end
      speakDelayed(addedCount)
    end
    _G.btnImportCancel.onClick = function()
      playSafeTone(ToneGenerator.TONE_CDMA_LOW_PBX_L, 120)
      dlgImp.dismiss()
    end
    dlgImp.show()
    updateDialogHeightDynamic(dlgImp, #rawItems, 0.95, 1)
    pcall(function()
      _G.impListView.setVerticalScrollBarEnabled(true)
      _G.impListView.setScrollbarFadingEnabled(false)
      _G.impListView.setSmoothScrollbarEnabled(true)
      _G.impListView.setOverScrollMode(View.OVER_SCROLL_ALWAYS)
    end)
  end
local function showClipboardPicker(targetEditText)
    playClipTone()
    local items = {}
    pcall(function()
      local list = service.getClipboardList()
      if list then
        local len = list.size and list.size() or #list
        for i = 0, len - 1 do
          table.insert(items, tostring(list[i] or ""))
        end
      end
    end)
    showSingleLinePicker(L("clipboard") .. ": " .. #items, items, targetEditText)
  end
  local function showFavoritesPicker(targetEditText)
    playFavTone()
    local items = {}
    pcall(function()
      local list = service.getFavoritesList()
      if list then
        local len = list.size and list.size() or #list
        for i = 0, len - 1 do
          table.insert(items, tostring(list[i] or ""))
        end
      end
    end)
    showSingleLinePicker(L("favorites") .. ": " .. #items, items, targetEditText)
  end
  local function showDeviceClipboardPicker(targetEditText)
    playSafeTone(ToneGenerator.TONE_PROP_BEEP, 120)
    local items = getDeviceClipboardList() or {}
    showSingleLinePicker(L("deviceClipboardTitle") .. ": " .. #items, items, targetEditText)
  end
  local openManageDialog
  refreshMemoAfterImport = function()
    currentList = t1
    searchMode = "titles"
    searchStage = 3
    pcall(function()
      if _G.searchEdit then
        _G.searchEdit.setVisibility(View.GONE)
        hideKeyboard(_G.searchEdit)
      end
      if _G.btnNoResult then _G.btnNoResult.setVisibility(View.GONE) end
      if _G.btnToggleMode then _G.btnToggleMode.setText(L("searchToggleTitle3")) end
    end)
    if _G.list then
      refreshListAdapterPreservePosition(_G.list, getStyledAdapter(t1))
    end
    if _G.emptyMemo then
      local empty = (#t1 == 0)
      _G.emptyMemo.setVisibility(empty and View.VISIBLE or View.GONE)
    end
    if _G.list then
      _G.list.setVisibility((#t1 == 0) and View.GONE or View.VISIBLE)
    end
    if scj then
      pcall(function()
        updateMainDialogPosition(scj, t1)
        updateDialogHeightDynamic(scj, #t1, 0.95, 1)
        scj.show()
      end)
    end
    pcall(function() updateInterfaceTexts() end)
  end
  local function openImportExportDialog(parentDlg)
    playSafeTone(ToneGenerator.TONE_PROP_BEEP, 120)
    local dlg = LuaDialog(service)
    dlg.setOnKeyListener(function(dialog, keyCode, event)
      if keyCode == KeyEvent.KEYCODE_BACK and event.getAction() == KeyEvent.ACTION_UP then
        dlg.dismiss()
        if parentDlg then
          parentDlg.show()
        end
        return true
      end
      return false
    end)
    local impLayout = {
      LinearLayout,
      orientation = "vertical",
      backgroundColor = BLUE_BG,
      layout_width = "match_parent",
      layout_height = "wrap_content",
      {
        TextView,
        text = L("importExport"),
        textColor = TEXT_COLOR,
        textSize = responsiveSp(L("importExport"), 35, 24, 16),
        singleLine = true,
        ellipsize = "end",
        backgroundColor = DARK_BLUE_TITLE,
        gravity = "center",
        padding = "10dp",
        typeface = Typeface.DEFAULT,
        layout_width = "match_parent"
      },
      {
        LinearLayout,
        orientation = "vertical",
        backgroundColor = BLUE_BG,
        layout_width = "match_parent",
        layout_height = "wrap_content",
        padding = "12dp",
        {
          Button,
          id = "btnImpChoice",
          text = L("importChoice"),
          textColor = TEXT_COLOR,
          textSize = "20sp",
          backgroundColor = GREEN_BG,
          layout_width = "match_parent",
          layout_height = "wrap_content",
          layout_marginBottom = "8dp",
          padding = "10dp"
        },
        {
          Button,
          id = "btnExpChoice",
          text = L("exportChoice"),
          textColor = TEXT_COLOR,
          textSize = "20sp",
          backgroundColor = GREEN_BG,
          layout_width = "match_parent",
          layout_height = "wrap_content",
          layout_marginBottom = "8dp",
          padding = "10dp"
        },
        {
          Button,
          id = "btnImpExportCancel",
          text = L("cancel"),
          textColor = TEXT_COLOR,
          textSize = "20sp",
          backgroundColor = BUTTON_BLUE,
          layout_width = "match_parent",
          layout_height = "wrap_content",
          padding = "10dp"
        }
      }
    }
    dlg.View = loadlayout(impLayout)
    _G.btnImpChoice.onClick = function()
      playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
      dlg.dismiss()
      local dlgImportType = LuaDialog(service)
      local importTypeLayout = {
        LinearLayout,
        orientation = "vertical",
        backgroundColor = BLUE_BG,
        layout_width = "match_parent",
        layout_height = "wrap_content",
        {
          TextView,
          text = L("importChoice"),
          textColor = TEXT_COLOR,
          textSize = responsiveSp(L("importChoice"), 35, 24, 16),
          singleLine = true,
          ellipsize = "end",
          backgroundColor = DARK_BLUE_TITLE,
          gravity = "center",
          padding = "10dp",
          typeface = Typeface.DEFAULT,
          layout_width = "match_parent"
        },
        {
          LinearLayout,
          orientation = "vertical",
          backgroundColor = BLUE_BG,
          layout_width = "match_parent",
          layout_height = "wrap_content",
          padding = "12dp",
          {
            Button,
            id = "btnSubImpClip",
            text = L("clipboard"),
            textColor = TEXT_COLOR,
            textSize = "20sp",
            backgroundColor = GREEN_BG,
            layout_width = "match_parent",
            layout_height = "wrap_content",
            layout_marginBottom = "8dp",
            padding = "10dp"
          },
          {
            Button,
            id = "btnSubImpFav",
            text = L("favorites"),
            textColor = TEXT_COLOR,
            textSize = "20sp",
            backgroundColor = GREEN_BG,
            layout_width = "match_parent",
            layout_height = "wrap_content",
            layout_marginBottom = "8dp",
            padding = "10dp"
          },
          {
            Button,
            id = "btnSubImpDeviceClip",
            text = L("importDeviceClip"),
            textColor = TEXT_COLOR,
            textSize = "20sp",
            backgroundColor = GREEN_BG,
            layout_width = "match_parent",
            layout_height = "wrap_content",
            layout_marginBottom = "8dp",
            padding = "10dp"
          },
          {
            Button,
            id = "btnSubImpCancel",
            text = L("cancel"),
            textColor = TEXT_COLOR,
            textSize = "20sp",
            backgroundColor = BUTTON_BLUE,
            layout_width = "match_parent",
            layout_height = "wrap_content",
            padding = "10dp"
          }
        }
      }
      dlgImportType.View = loadlayout(importTypeLayout)
      pcall(function()
        local cCount, fCount, dcCount = 0, 0, 0
        local c = service.getClipboardList()
        if c then cCount = c.size and c.size() or #c end
        local f = service.getFavoritesList()
        if f then fCount = f.size and f.size() or #f end
        dcCount = #(getDeviceClipboardList() or {})
        _G.btnSubImpClip.setText(L("clipboard") .. ": " .. cCount)
        _G.btnSubImpFav.setText(L("favorites") .. ": " .. fCount)
        _G.btnSubImpDeviceClip.setText(L("deviceClipboardTitle") .. ": " .. dcCount)
      end)
      dlgImportType.setOnKeyListener(function(dialog, keyCode, event)
        if keyCode == KeyEvent.KEYCODE_BACK and event.getAction() == KeyEvent.ACTION_UP then
          dlgImportType.dismiss()
          dlg.show()
          return true
        end
        return false
      end)
      _G.btnSubImpClip.onClick = function()
        dlgImportType.dismiss()
        local t3 = {}
        pcall(function()
          local clipList = service.getClipboardList()
          if clipList then
            local len = clipList.size and clipList.size() or #clipList
            for i = 0, len - 1 do table.insert(t3, tostring(clipList[i] or "")) end
          end
        end)
        showImportSingleLinePicker(L("clipboard") .. ": " .. #t3, t3, false, nil, dlgImportType)
      end
      _G.btnSubImpFav.onClick = function()
        dlgImportType.dismiss()
        local t3 = {}
        pcall(function()
          local favList = service.getFavoritesList()
          if favList then
            local len = favList.size and favList.size() or #favList
            for i = 0, len - 1 do table.insert(t3, tostring(favList[i] or "")) end
          end
        end)
        showImportSingleLinePicker(L("favorites") .. ": " .. #t3, t3, true, nil, dlgImportType)
      end
      _G.btnSubImpDeviceClip.onClick = function()
        dlgImportType.dismiss()
        local t3 = getDeviceClipboardList()
        showImportSingleLinePicker(L("deviceClipboardTitle") .. ": " .. #t3, t3, false, "deviceClip", dlgImportType)
      end
      _G.btnSubImpCancel.onClick = function()
        playSafeTone(ToneGenerator.TONE_CDMA_LOW_PBX_L, 120)
        dlgImportType.dismiss()
        dlg.show()
      end
      dlgImportType.show()
    end
    _G.btnExpChoice.onClick = function()
      playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
      dlg.dismiss()
      openManageDialog(dlg)
    end
    _G.btnImpExportCancel.onClick = function()
      playSafeTone(ToneGenerator.TONE_CDMA_LOW_PBX_L, 120)
      dlg.dismiss()
    end
    dlg.show()
  end
  searchMode = "titles"
  searchStage = 3
  currentList = t1
  updateInterfaceTexts = function()
    if _G.textview then
      _G.textview.setText(L("memoHeader"))
      _G.textview.setContentDescription(L("memoHeader"))
    end
    if _G.emptyMemo then
      _G.emptyMemo.setText(L("memoEmpty"))
      _G.emptyMemo.setContentDescription(L("memoEmpty"))
    end
    if _G.btnToggleMode then
      if searchStage == 1 then
        _G.btnToggleMode.setText(L("searchToggleTitle2"))
      elseif searchStage == 2 then
        _G.btnToggleMode.setText(L("searchToggleTitle1"))
      else
        _G.btnToggleMode.setText(L("searchToggleTitle3"))
      end
    end
  end
  local function openEditTitleDialog(ii)
    playSafeTone(ToneGenerator.TONE_PROP_BEEP, 120)
    local currentTitle = t1[ii] or ""
    local dlgEditT = LuaDialog(service)
    local editTitleLayout = {
      LinearLayout,
      orientation = "vertical",
      backgroundColor = BLUE_BG,
      layout_width = "match_parent",
      layout_height = "wrap_content",
      padding = "0dp",
      {
        TextView,
        text = L("editTitle"),
        textColor = TEXT_COLOR,
        textSize = responsiveSp(L("editTitle"), 35, 24, 16),
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
        id = "edEditTitle",
        text = currentTitle,
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
        padding = "0dp",
        layout_marginBottom = "4dp",
        {
          Button,
          id = "btnEditTitleClip",
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
          id = "btnEditTitleFav",
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
          id = "btnEditTitleDeviceClip",
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
          id = "btnEditTitleDone",
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
          id = "btnEditTitleCancel",
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
    dlgEditT.View = loadlayout(editTitleLayout)
    setupTitleLimiter(_G.edEditTitle)
    _G.btnEditTitleClip.onClick = function()
      showClipboardPicker(_G.edEditTitle)
    end
    _G.btnEditTitleFav.onClick = function()
      showFavoritesPicker(_G.edEditTitle)
    end
    _G.btnEditTitleDeviceClip.onClick = function()
      showDeviceClipboardPicker(_G.edEditTitle)
    end
    _G.btnEditTitleDone.onClick = function()
      playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
      local newTitle = tostring(_G.edEditTitle.getText() or "")
      if newTitle:gsub("%s+", "") == "" then
        speakDelayed(L("emptyTitleMsg"))
        return
      end
      t1[ii] = newTitle
      f1:write(t1)
      currentList = (searchMode == "titles") and t1 or t2
      refreshListAdapterPreservePosition(_G.list, getStyledAdapter(currentList))
      updateMainDialogPosition(scj, currentList)
      updateDialogHeightDynamic(scj, #currentList, 0.95, 1)
      dlgEditT.dismiss()
      speakDelayed(L("editTitleSuccess"))
    end
    _G.btnEditTitleCancel.onClick = function()
      playSafeTone(ToneGenerator.TONE_CDMA_LOW_PBX_L, 120)
      dlgEditT.dismiss()
    end
    dlgEditT.show()
    focusAndShowKeyboard(_G.edEditTitle)
    pcall(function()
      local window = dlgEditT.getWindow()
      if window then
        window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE)
      end
    end)
  end
local function openEditContentDialog(ii)
    playSafeTone(ToneGenerator.TONE_PROP_BEEP, 120)
    local currentContent = t2[ii] or ""
    local dlgEditC = LuaDialog(service)
    local editContentLayout = {
      LinearLayout,
      orientation = "vertical",
      backgroundColor = BLUE_BG,
      layout_width = "match_parent",
      layout_height = "wrap_content",
      padding = "0dp",
      {
        TextView,
        text = L("editContent"),
        textColor = TEXT_COLOR,
        textSize = responsiveSp(L("editContent"), 35, 24, 16),
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
        id = "edEditContent",
        text = currentContent,
        textColor = TEXT_COLOR,
        hintTextColor = 0xAAFFFFFF,
        textSize = "20sp",
        backgroundColor = BLUE_BG,
        layout_width = "match_parent",
        layout_height = math.floor(service.getResources().getDisplayMetrics().heightPixels * 0.40),
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
        padding = "0dp",
        layout_marginBottom = "4dp",
        {
          Button,
          id = "btnEditContentClip",
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
          id = "btnEditContentFav",
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
          id = "btnEditContentDeviceClip",
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
          id = "btnEditContentDone",
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
          id = "btnEditContentCancel",
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
    dlgEditC.View = loadlayout(editContentLayout)
    _G.btnEditContentClip.onClick = function()
      showClipboardPicker(_G.edEditContent)
    end
    _G.btnEditContentFav.onClick = function()
      showFavoritesPicker(_G.edEditContent)
    end
    _G.btnEditContentDeviceClip.onClick = function()
      showDeviceClipboardPicker(_G.edEditContent)
    end
    _G.btnEditContentDone.onClick = function()
      local newContent = tostring(_G.edEditContent.getText() or "")
      if newContent:gsub("%s+", "") == "" then
        playSafeTone(ToneGenerator.TONE_CDMA_LOW_PBX_L, 150)
        speakDelayed(L("emptyContentMsg"))
        return
      end
      playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
      t2[ii] = newContent
      f2:write(t2)
      currentList = (searchMode == "titles") and t1 or t2
      refreshListAdapterPreservePosition(_G.list, getStyledAdapter(currentList))
      updateMainDialogPosition(scj, currentList)
      updateDialogHeightDynamic(scj, #currentList, 0.95, 1)
      dlgEditC.dismiss()
      speakDelayed(L("editContentSuccess"))
    end
    _G.btnEditContentCancel.onClick = function()
      playSafeTone(ToneGenerator.TONE_CDMA_LOW_PBX_L, 120)
      dlgEditC.dismiss()