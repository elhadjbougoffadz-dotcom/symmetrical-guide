    end
    dlgEditC.show()
    focusAndShowKeyboard(_G.edEditContent)
    pcall(function()
      local window = dlgEditC.getWindow()
      if window then
        window.setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_RESIZE)
      end
    end)
  end
  openManageDialog = function(parentDlg)
    playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
    local dlgManage = LuaDialog(service)
    local selectedItems = {}
    local rangeStartIndex = nil
    local rangeUnselectStartIndex = nil
    local function returnToParent()
      dlgManage.dismiss()
      if parentDlg then
        pcall(function()
          -- عند الرجوع من "إدارة العناصر" إلى الإعدادات لا نعامل
          -- نافذة الإعدادات كأنها نافذة المذكرة الرئيسية.
          -- refreshMemoView يغيّر أبعاد نافذة المذكرة، وهذا كان سبب
          -- اختفاء الجزء السفلي من واجهة الإعدادات.
          if parentDlg == scj then
            currentList = (searchMode == "titles") and t1 or t2
            refreshMemoView(parentDlg, currentList)
          else
            parentDlg.show()
          end
        end)
      end
    end
    dlgManage.setOnKeyListener(function(dialog, keyCode, event)
      if keyCode == KeyEvent.KEYCODE_BACK and event.getAction() == KeyEvent.ACTION_UP then
        returnToParent()
        return true
      end
      return false
    end)
    local function getSelectedCount()
      local count = 0
      for i = 1, #t1 do
        if selectedItems[i] then count = count + 1 end
      end
      return count
    end
    local manageListData = {}
    for idx, v in ipairs(t1) do
      local rawStr = tostring(v or "")
      local line1 = rawStr:match("([^\r\n]+)") or rawStr
      local isSelected = selectedItems[idx] or false
      local desc = line1 .. ", " .. (isSelected and L("itemSelectedSpoken") or L("itemDeselectedSpoken"))
      table.insert(manageListData, {
        itemRoot = {
          backgroundColor = isSelected and GREY_BG or BLUE_BG
        },
        title = {
          text = (isSelected and "✓ " or "") .. line1,
          contentDescription = desc
        }
      })
    end
    local manageAdapter = LuaAdapter(service, manageListData, grid_item_layout)
    local manageLayout = {
      LinearLayout,
      orientation = "vertical",
      backgroundColor = BLUE_BG,
      layout_width = "match_parent",
      layout_height = "match_parent",
      {
        TextView,
        text = L("manageTitle"),
        textColor = TEXT_COLOR,
        textSize = responsiveSp(L("manageTitle"), 35, 24, 16),
        singleLine = true,
        ellipsize = "end",
        backgroundColor = DARK_BLUE_TITLE,
        gravity = "center",
        layout_width = "match_parent",
        layout_height = "wrap_content",
        padding = "12dp",
        typeface = Typeface.DEFAULT
      },
      {
        LinearLayout,
        orientation = "horizontal",
        backgroundColor = BLUE_BG,
        layout_width = "match_parent",
        layout_height = "wrap_content",
        padding = "4dp",
        {
          Button,
          id = "btnManageImportExport",
          text = L("importExport"),
          textColor = TEXT_COLOR,
          textSize = "14.28sp",
          backgroundColor = BROWN_BTN,
          layout_width = "0dp",
          layout_height = "wrap_content",
          layout_weight = "1",
          layout_marginRight = "2dp"
        },
        {
          Button,
          id = "btnSelectAll",
          text = L("selectAll"),
          textColor = TEXT_COLOR,
          textSize = "14.28sp",
          backgroundColor = BROWN_BTN,
          layout_width = "0dp",
          layout_height = "wrap_content",
          layout_weight = "1",
          layout_marginRight = "2dp"
        },
        {
          Button,
          id = "btnInvertSelection",
          text = L("invertSelection"),
          textColor = TEXT_COLOR,
          textSize = "14.28sp",
          backgroundColor = BROWN_BTN,
          layout_width = "0dp",
          layout_height = "wrap_content",
          layout_weight = "1"
        }
      },
      {
        FrameLayout,
        layout_width = "match_parent",
        layout_height = "0dp",
        layout_weight = "1",
        {
          GridView,
          id = "manageList",
          numColumns = currentColumns,
          layout_width = "match_parent",
          layout_height = "match_parent",
          padding = "0dp"
        },
        {
          TextView,
          id = "manageEmpty",
          text = L("manageEmpty"),
          textColor = 0xFFFFFFFF,
          textSize = responsiveLatinSp(L("manageEmpty"), 40, 22, 14, 8),
          backgroundColor = 0xFF000000,
          typeface = Typeface.DEFAULT_BOLD,
          gravity = "center",
          layout_width = "match_parent",
          layout_height = "match_parent",
          visibility = View.GONE
        }
      },
      {
        LinearLayout,
        orientation = "horizontal",
        backgroundColor = BLUE_BG,
        layout_width = "match_parent",
        layout_height = "wrap_content",
        padding = "4dp",
        {
          Button,
          id = "btnManageShare",
          text = L("share"),
          textColor = TEXT_COLOR,
          textSize = "15sp",
          backgroundColor = BUTTON_BLUE,
          layout_width = "0dp",
          layout_height = "wrap_content",
          layout_weight = "1",
          layout_marginRight = "2dp"
        },
        {
          Button,
          id = "btnManageExportClip",
          text = L("exportClip"),
          textColor = TEXT_COLOR,
          textSize = "10sp",
          backgroundColor = BUTTON_BLUE,
          layout_width = "0dp",
          layout_height = "wrap_content",
          layout_weight = "1",
          layout_marginRight = "2dp"
        },
        {
          Button,
          id = "btnManageExportFav",
          text = L("exportFav"),
          textColor = TEXT_COLOR,
          textSize = "10sp",
          backgroundColor = BUTTON_BLUE,
          layout_width = "0dp",
          layout_height = "wrap_content",
          layout_weight = "1",
          layout_marginRight = "2dp"
        },
        {
          Button,
          id = "btnManageExportDeviceClip",
          text = L("exportDeviceClip"),
          textColor = TEXT_COLOR,
          textSize = "10sp",
          backgroundColor = BUTTON_BLUE,
          layout_width = "0dp",
          layout_height = "wrap_content",
          layout_weight = "1",
          layout_marginRight = "2dp"
        },
        {
          Button,
          id = "btnManageDelete",
          text = L("delete"),
          textColor = TEXT_COLOR,
          textSize = "15sp",
          backgroundColor = BUTTON_BLUE,
          layout_width = "0dp",
          layout_height = "wrap_content",
          layout_weight = "1"
        }
      },
      {
        Button,
        id = "btnManageCancel",
        text = L("cancel"),
        textColor = TEXT_COLOR,
        textSize = "15sp",
        backgroundColor = BUTTON_BLUE,
        layout_width = "match_parent",
        layout_height = "wrap_content",
        layout_marginTop = "4dp",
        padding = "10dp"
      }
    }
    dlgManage.View = loadlayout(manageLayout)
    local manageList = _G.manageList
    local manageEmpty = _G.manageEmpty
    local btnManageImportExport = _G.btnManageImportExport
    local btnSelectAll = _G.btnSelectAll
    local btnInvertSelection = _G.btnInvertSelection
    local btnManageShare = _G.btnManageShare
    local btnManageExportFav = _G.btnManageExportFav
    local btnManageExportClip = _G.btnManageExportClip
    local btnManageExportDeviceClip = _G.btnManageExportDeviceClip
    local btnManageDelete = _G.btnManageDelete
    local btnManageCancel = _G.btnManageCancel
    local function syncManageListData()
      for idx, v in ipairs(t1) do
        local rawStr = tostring(v or "")
        local line1 = rawStr:match("([^\r\n]+)") or rawStr
        local isSelected = selectedItems[idx] or false
        local desc = line1 .. ", " .. (isSelected and L("itemSelectedSpoken") or L("itemDeselectedSpoken"))
        if not manageListData[idx] then
          manageListData[idx] = {}
        end
        if not manageListData[idx].itemRoot then
          manageListData[idx].itemRoot = {}
        end
        if not manageListData[idx].title then
          manageListData[idx].title = {}
        end
        manageListData[idx].itemRoot.backgroundColor = isSelected and GREY_BG or BLUE_BG
        manageListData[idx].title.text = (isSelected and "✓ " or "") .. line1
        manageListData[idx].title.contentDescription = desc
      end
      for i = #manageListData, #t1 + 1, -1 do
        table.remove(manageListData, i)
      end
    end

    local function updateVisibleManageSelectionViews()
      syncManageListData()
      pcall(function()
        local first = manageList.getFirstVisiblePosition() or 0
        local childCount = manageList.getChildCount() or 0
        for childIndex = 0, childCount - 1 do
          local child = manageList.getChildAt(childIndex)
          local itemIndex = first + childIndex + 1
          if child and t1[itemIndex] then
            local rawStr = tostring(t1[itemIndex] or "")
            local line1 = rawStr:match("([^\r\n]+)") or rawStr
            local isSelected = selectedItems[itemIndex] or false
            local desc = line1 .. ", " .. (isSelected and L("itemSelectedSpoken") or L("itemDeselectedSpoken"))
            child.setBackgroundColor(isSelected and GREY_BG or BLUE_BG)
            local row = child.getChildAt(0)
            local title = row and row.getChildAt(0) or nil
            if title then
              title.setText((isSelected and "✓ " or "") .. line1)
              title.setContentDescription(desc)
            end
          end
        end
      end)
    end

    local function refreshManageList(preservedPos, resizeDialog)
      local currentPos = preservedPos or captureListPosition(manageList)
      syncManageListData()
      if manageAdapter then
        pcall(function() manageAdapter.notifyDataSetChanged() end)
      end
      pcall(function()
        manageList.setVisibility(#t1 == 0 and View.GONE or View.VISIBLE)
      end)
      if manageEmpty then
        manageEmpty.setVisibility(#t1 == 0 and View.VISIBLE or View.GONE)
      end
      pcall(function()
        btnSelectAll.setText(L("selectAll"))
        btnSelectAll.setContentDescription(L("selectAll"))
        btnInvertSelection.setText(L("invertSelection"))
        btnInvertSelection.setContentDescription(L("invertSelection"))
      end)
      if resizeDialog then
        applyMainDialogConstraints(dlgManage, #t1 > 0)
        updateDialogHeightDynamic(dlgManage, #t1, 0.95, 1)
      end
      if #t1 > 0 then
        restoreListPosition(manageList, currentPos, 40)
      else
        pcall(function() manageList.setSelection(-1) end)
      end
      pcall(function()
        dlgManage.show()
        updateDialogHeightDynamic(dlgManage, #t1, 0.95, 1)
      end)
    end
    refreshManageAfterDataChange = function()
      currentList = t1
      searchMode = "titles"
      searchStage = 3
      refreshManageList(nil, true)
      pcall(function() refreshMemoView(scj, currentList) end)
      task(100, function() pcall(function() refreshManageList(nil, true) end) end)
      task(300, function() pcall(function() refreshManageList(nil, true) end) end)
      task(600, function() pcall(function() refreshManageList(nil, true) end) end)
    end
    manageList.adapter = manageAdapter
    btnSelectAll.onClick = function()
      playSafeTone(ToneGenerator.TONE_PROP_BEEP, 120)
      rangeStartIndex = nil
      rangeUnselectStartIndex = nil
      if #t1 == 0 then
        service.speak(L("selectItemsToDelete"))
        return
      end
      local allSelected = true
      for i = 1, #t1 do
        if not selectedItems[i] then
          allSelected = false
          break
        end
      end
      if allSelected then
        selectedItems = {}
        btnSelectAll.setText(L("selectAll"))
        btnSelectAll.setContentDescription(L("selectAll"))
        service.speak(L("cancelSelectAllSpoken"))
      else
        selectedItems = {}
        for i = 1, #t1 do
          selectedItems[i] = true
        end
        btnSelectAll.setText(L("cancelSelectAll"))
        btnSelectAll.setContentDescription(L("cancelSelectAll"))
        service.speak(L("selectAllSpoken") .. #t1)
      end
      updateVisibleManageSelectionViews()
    end
    btnInvertSelection.onClick = function()
      playSafeTone(ToneGenerator.TONE_PROP_BEEP, 120)
      rangeStartIndex = nil
      rangeUnselectStartIndex = nil
      if #t1 == 0 then return end
      for i = 1, #t1 do
        selectedItems[i] = not (selectedItems[i] or false)
      end
      local selCount = 0
      local deselCount = 0
      for i = 1, #t1 do
        if selectedItems[i] then selCount = selCount + 1 else deselCount = deselCount + 1 end
      end
      local allSelCheck = selCount == #t1
      if allSelCheck then
        btnSelectAll.setText(L("cancelSelectAll"))
      else
        btnSelectAll.setText(L("selectAll"))
      end
      local spoken = string.format(L("invertSelectionSpoken"), selCount, deselCount)
      btnInvertSelection.setText(L("invertSelection"))
      btnInvertSelection.setContentDescription(L("invertSelection") .. ", " .. spoken)
      service.speak(spoken)
      updateVisibleManageSelectionViews()
    end
    manageList.onItemClick = function(parent, view, position, id)
      playSafeTone(ToneGenerator.TONE_CDMA_KEYPAD_VOLUME_KEY_LITE, 100)
      local index = position + 1
      if not t1[index] then return end
      selectedItems[index] = not selectedItems[index]
      rangeStartIndex = nil
      rangeUnselectStartIndex = nil
      local allSelCheck = true
      for i = 1, #t1 do
        if not selectedItems[i] then allSelCheck = false break end
      end
      if allSelCheck then
        btnSelectAll.setText(L("cancelSelectAll"))
      else
        btnSelectAll.setText(L("selectAll"))
      end
      local statusText = selectedItems[index] and L("itemSelectedSpoken") or L("itemDeselectedSpoken")
      speakDelayed(statusText)
      updateVisibleManageSelectionViews()
    end
    manageList.onItemLongClick = function(parent, view, position, id)
      playSafeTone(ToneGenerator.TONE_SUP_CONGESTION_ABBREV, 200)
      local index = position + 1
      if not t1[index] then return end
      if selectedItems[index] then
        if not rangeUnselectStartIndex then
          rangeUnselectStartIndex = index
          selectedItems[index] = false
          speakDelayed(L("itemDeselectedSpoken"))
        else
          local startIdx = math.min(rangeUnselectStartIndex, index)
          local endIdx = math.max(rangeUnselectStartIndex, index)
          for i = startIdx, endIdx do
            selectedItems[i] = false
          end
          rangeUnselectStartIndex = nil
          speakDelayed(L("itemDeselectedSpoken"))
        end
      else
        local allSelected = true
        for i = 1, #t1 do
          if not selectedItems[i] then
            allSelected = false
            break
          end
        end
        if allSelected then
          speakDelayed(L("selectAllSpoken"))
          return true
        end
        if not rangeStartIndex then
          rangeStartIndex = index
          selectedItems[index] = true
          speakDelayed(L("rangeStartSpoken"))
        else
          local startIdx = math.min(rangeStartIndex, index)
          local endIdx = math.max(rangeStartIndex, index)
          for i = startIdx, endIdx do
            selectedItems[i] = true
          end
          local rangeCount = (endIdx - startIdx + 1)
          rangeStartIndex = nil
          speakDelayed(L("rangeSelectedMsg") .. rangeCount)
        end
      end
      local allSelCheck = true
      for i = 1, #t1 do
        if not selectedItems[i] then allSelCheck = false break end
      end
      if allSelCheck then
        btnSelectAll.setText(L("cancelSelectAll"))
      else
        btnSelectAll.setText(L("selectAll"))
      end
      updateVisibleManageSelectionViews()
      return true
    end
    btnManageShare.onClick = function()
      playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
      if getSelectedCount() == 0 then
        speakDelayed(L("selectItemsToDelete"))
        return
      end
      local combinedText = ""
      for i = 1, #t1 do
        if selectedItems[i] then
          local itemText = (t1[i] or "") .. (t2[i] and t2[i] ~= "" and ("\n" .. t2[i]) or "")
          if combinedText == "" then
            combinedText = itemText
          else
            combinedText = combinedText .. "\n\n------------------\n\n" .. itemText
          end
        end
      end
      dlgManage.dismiss()
      if scj then scj.dismiss() end
      pcall(function()
        local intent = Intent(Intent.ACTION_SEND)
        intent.setType("text/plain")
        intent.putExtra(Intent.EXTRA_TEXT, combinedText)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        service.startActivity(Intent.createChooser(intent, L("sharePrompt")))
      end)
    end
    btnManageExportFav.onClick = function()
      playFavTone()
      local exportedCount = getSelectedCount()
      if exportedCount == 0 then
        speakDelayed(L("selectItemsToDelete"))
        return
      end
      local ok = pcall(function()
        for i = 1, #t1 do
          if selectedItems[i] then
            local fullText = (t1[i] or "") .. (t2[i] and t2[i] ~= "" and ("\n" .. t2[i]) or "")
            if service.addFavorites then
              service.addFavorites(fullText)
            else
              error("addFavorites unavailable")
            end
          end
        end
      end)
      if ok then
        showExportNotice(L("exportFavSuccess2"))
      else
        speakDelayed(L("exportFavFailed"))
      end
    end
    btnManageExportClip.onClick = function()
      playClipTone()
      local exportedCount = getSelectedCount()
      if exportedCount == 0 then
        speakDelayed(L("selectItemsToDelete"))
        return
      end
      local ok = pcall(function()
        for i = 1, #t1 do
          if selectedItems[i] then
            local itemTextToCopy = (t1[i] or "") .. (t2[i] and t2[i] ~= "" and ("\n" .. t2[i]) or "")
            if service.copy then
              service.copy(itemTextToCopy)
            else
              error("copy unavailable")
            end
          end
        end
      end)
      if ok then
        showExportNotice(L("exportClipSuccess2"))
      else
        speakDelayed(L("exportClipFailed"))
      end
    end
    btnManageExportDeviceClip.onClick = function()
      playClipTone()
      local exportedCount = getSelectedCount()
      if exportedCount == 0 then
        speakDelayed(L("selectItemsToDelete"))
        return
      end
      local ok = pcall(function()
        local deviceClip = getDeviceClipboardList()
        for i = 1, #t1 do
          if selectedItems[i] then
            local fullText = (t1[i] or "") .. (t2[i] and t2[i] ~= "" and ("\n" .. t2[i]) or "")
            table.insert(deviceClip, fullText)
          end
        end
        writeDeviceStore(fDeviceClipboard, deviceClip)
      end)
      if ok then
        showExportNotice(L("exportDeviceSuccess2"))
      else
        speakDelayed(L("exportDeviceFailed"))
      end
    end
    btnManageImportExport.onClick = function()
      playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
      openImportExportDialog(dlgManage)
    end
    btnManageCancel.onClick = function()
      playSafeTone(ToneGenerator.TONE_CDMA_LOW_PBX_L, 120)
      returnToParent()
    end
    btnManageDelete.onClick = function()
      playSafeTone(ToneGenerator.TONE_CDMA_ALERT_NETWORK_LITE, 180)
      local selectedCount = getSelectedCount()
      if selectedCount == 0 then
        speakDelayed(L("selectItemsToDelete"))
        return
      end
      local promptText = (selectedCount == 1) and L("deletePrompt1") or ((selectedCount == 2) and L("deletePrompt2") or (L("deletePromptMany") .. selectedCount .. L("deletePromptManySuffix")))
      local dlgConfirm = LuaDialog(service)
      local confirmLayout = {
        LinearLayout,
        orientation = "vertical",
        backgroundColor = BLUE_BG,
        layout_width = "match_parent",
        layout_height = "wrap_content",
        padding = "16dp",
        {
          TextView,
          text = promptText,
          textColor = TEXT_COLOR,
          textSize = "30sp",
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
          LinearLayout,
          orientation = "horizontal",
          backgroundColor = BLUE_BG,
          layout_width = "match_parent",
          layout_height = "wrap_content",
          layout_marginTop = "16dp",
          {
            Button,
            id = "btnConfirmCancel",
            text = L("cancel"),
            textColor = TEXT_COLOR,
            textSize = "14.28sp",
            backgroundColor = BUTTON_BLUE,
            layout_width = "0dp",
            layout_height = "wrap_content",
            layout_weight = "1",
            layout_marginRight = "6dp"
          },
          {
            Button,
            id = "btnConfirmDelete",
            text = L("clear"),
            textColor = TEXT_COLOR,
            textSize = "14.28sp",
            backgroundColor = DELETE_RED,
            layout_width = "0dp",
            layout_height = "wrap_content",
            layout_weight = "1"
          }
        }
      }
      dlgConfirm.View = loadlayout(confirmLayout)
      _G.btnConfirmCancel.onClick = function() dlgConfirm.dismiss() end
      _G.btnConfirmDelete.onClick = function()
        playSafeTone(ToneGenerator.TONE_PROP_ACK, 150)
        for idx = #t1, 1, -1 do
          if selectedItems[idx] then
            table.remove(t1, idx)
            table.remove(t2, idx)
          end
        end
        f1:write(t1)
        f2:write(t2)
        selectedItems = {}
        rangeStartIndex = nil
        rangeUnselectStartIndex = nil
        btnSelectAll.setText(L("selectAll"))
        currentList = (searchMode == "titles") and t1 or t2
        dlgConfirm.dismiss()
        -- بعد الحذف، تبقى داخل "إدارة العناصر" حتى لو أصبحت القائمة فارغة.
        -- يتم تحديث الإدارة والمذكرة فورًا حتى لا تعود العناصر القديمة عند الرجوع.
        if refreshManageAfterDataChange then
          refreshManageAfterDataChange()
        else
          refreshManageList(nil, true)
          refreshMemoView(scj, currentList)
        end
        if #t1 == 0 then
          pcall(function()
            manageList.setSelection(-1)
            if manageEmpty then manageEmpty.setVisibility(View.VISIBLE) end
            btnSelectAll.setText(L("selectAll"))
            btnSelectAll.setContentDescription(L("selectAll"))
          end)
        end
        speakDelayed(L("deleteSuccess"))
      end
      dlgConfirm.show()
    end
    applyMainDialogConstraints(dlgManage, #t1 > 0)
    if manageEmpty then
      manageEmpty.setVisibility(#t1 == 0 and View.VISIBLE or View.GONE)
    end
    updateDialogHeightDynamic(dlgManage, #t1, 0.95, 1)
  end