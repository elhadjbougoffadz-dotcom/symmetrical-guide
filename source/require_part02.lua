    homeBtn = "Home",
    addBtn = "Add",
    exitBtn = "Exit",
    settingsBtn = "Settings",
    clipboard = "Jieshuo Clipboard",
    favorites = "Jieshuo Favorites",
    done = "Done",
    cancel = "Cancel",
    next = "Next",
    editTitle = "Edit Title",
    editContent = "Edit Content",
    settingsTitle = "Settings",
    manageItems = "Manage Items",
    importExport = "Import and Export",
    changeLang = "Change Language",
    memoStats = "Memo Statistics",
    moreInfo = "More Information",
    backupRestore = "Backup and Restore",
    createBackup = "Create Backup",
    restoreBackup = "Restore Backup",
    backupMemo = "Smart Note",
    backupJieshuoClipboard = "Jieshuo Clipboard",
    backupJieshuoFavorites = "Jieshuo Favorites",
    backupDeviceClipboard = "Device Clipboard",
    backupSelectTitle = "What do you want to back up?",
    restoreSelectTitle = "What do you want to restore from the backup?",
    restoreConfirmMessage = "The note will be initialized with the new backup and the selected data will replace the data in the backup. Do you want to continue?",
    backupConfirmMessage = "The selected stored backups will be deleted and replaced with these new backups. Do you want to continue?",
    selected = "Selected",
    unselected = "Unselected",
    allSelected = "All selected",
    allDeselected = "All selection cancelled",
    printSplitLines = "Split into Lines",
    printWholeText = "Whole Text",
    enhancedDescription = "Enhanced version with multilingual support.",
    languageSelected = "Selected",
    langSelectedSpoken = "English language, selected",
    languageChanged = "English language selected",
    selectLangTitle = "Select Language",
    langAr = "Arabic (ARABIC)",
    langFr = "French (FRENCH)",
    langEn = "English (ENGLISH)",
    changeColumns = "Change Display (Columns)",
    selectColumnsTitle = "Select Grid Columns",
    col1 = "Normal (1 Column)",
    col2 = "2 Columns Grid",
    col3 = "3 Columns Grid",
    col4 = "4 Columns Grid",
    manageTitle = "Manage Items",
    selectAll = "Select All",
    cancelSelectAll = "Deselect All",
    invertSelection = "Invert Selection",
    share = "Share",
    exportClip = "To Jieshuo Clipboard",
    exportFav = "To Jieshuo Favorites",
    importDeviceClip = "Import from Device Clipboard",
    exportDeviceClip = "Export to Device Clipboard",
    emptyDeviceClipMsg = "Device clipboard is empty",
    deviceClipboardTitle = "Device Clipboard",
    exportDeviceClipSuccess = "Exported to device clipboard successfully",
    delete = "Delete",
    addContentTitle = "Add Content",
    contentHint = "Write content here...",
    addTitleTitle = "Add Title",
    titleHint = "Write title here...",
    itemOptions = "Item Options",
    actionTitle = "Select Action",
    paste = "Paste",
    copy = "Copy",
    print = "Print Content",
    clear = "Clear",
    noteCountMsg = "Note items ",
    clipCountMsg = ", Jieshuo clipboard items ",
    favCountMsg = ", Jieshuo favorite items ",
    titleLimitMsg = "Title cannot exceed 40 characters",
    emptyTitleMsg = "Please write the title first",
    emptyContentMsg = "This action requires content",
    emptyClipMsg = "Clipboard is empty",
    emptyFavMsg = "Favorites are empty",
    editTitleSuccess = "Title updated successfully",
    editContentSuccess = "Content updated successfully",
    addSuccess = "Item added successfully",
    deleteSuccess = "Items deleted successfully",
    exportClipSuccess = "Exported to clipboard successfully",
    exportFavSuccess = "Exported to favorites successfully",
    singleDeleteSuccess = "Item deleted successfully",
    allDeleteSuccess = "All items deleted successfully",
    copied = "Copied",
    calling = "Calling...",
    notANumber = "Not a valid phone number",
    openLink = "Opening link...",
    noLink = "No link to open",
    movedFirst = "Moved to the top",
    movedTop = "Moved up",
    alreadyTop = "Item is already at the top",
    manualMoveHint = "Move focus to the desired place, then double tap",
    movedLast = "Moved to the bottom",
    movedBottom = "Moved down",
    alreadyBottom = "Item is already at the bottom",
    selectItemsToDelete = "No items selected for deletion",
    deletePrompt1 = "Do you want to delete this item?",
    deletePrompt2 = "Do you want to delete 2 items?",
    deletePromptMany = "Do you want to delete ",
    deletePromptManySuffix = " items?",
    sharePrompt = "Share note via",
    selectAllSpoken = "All items have been selected",
    cancelSelectAllSpoken = "Deselection of all items has been cancelled",
    itemSelectedSpoken = "Selected",
    itemDeselectedSpoken = "Unselected",
    rangeStartSpoken = "Selection started from current item by long press and selecting between them.",
    rangeSelectedMsg = "Selected items between the two points, number of selected items: ",
    menuOpt1 = "Edit title or content",
    menuOpt2 = "Copy title or both",
    menuOpt3 = "Call or open link",
    menuOpt4 = "Move to top or bottom",
    menuOpt5 = "Move up or down",
    menuOpt6 = "Manual move",
    menuOpt7 = "Delete or delete all",
    menuOpt8 = "Select Items"
  }
}
local function responsiveSp(text, baseSize, minSize, threshold)
  local size = tonumber(baseSize) or 20
  local min = tonumber(minSize) or math.max(14, size - 5)
  local limit = tonumber(threshold) or 18
  local value = tostring(text or "")
  local length = #value
  pcall(function()
    if utf8 and utf8.len(value) then length = utf8.len(value) end
  end)
  if length > limit then
    local extra = length - limit
    local step = (size >= 30) and 3 or 4
    size = math.max(min, size - math.ceil(extra / step))
  end
  return tostring(size) .. "sp"
end

local function responsiveLatinSp(text, baseSize, minSize, threshold, extraReduction)
  local sizeText = responsiveSp(text, baseSize, minSize, threshold)
  if currentLang ~= "ar" then
    local n = tonumber(tostring(sizeText):match("([%d%.]+)")) or tonumber(baseSize) or 20
    local floorSize = tonumber(minSize) or math.max(14, (tonumber(baseSize) or 20) - 5)
    n = math.max(floorSize, n - (tonumber(extraReduction) or 3))
    if currentLang == "fr" then
      n = math.max(floorSize, n - 1)
    end
    return tostring(n) .. "sp"
  end
  return sizeText
end

local function L(key)
  local dict = langDict[currentLang] or langDict.ar
  return dict[key] or langDict.ar[key] or key
end
local grid_item_layout = {
  LinearLayout,
  id = "itemRoot",
  orientation = "horizontal",
  backgroundColor = BLUE_BG,
  layout_width = "match_parent",
  layout_height = "wrap_content",
  padding = "0dp",
  {
    LinearLayout,
    orientation = "horizontal",
    layout_width = "match_parent",
    layout_height = "wrap_content",
    gravity = "center_vertical",
    {
      TextView,
      id = "title",
      textColor = TEXT_COLOR,
      textSize = "15.35sp",
      gravity = "center",
      textAlignment = "center",
      -- عرض سطر واحد فقط مثل العنوان، مع قص بقية المحتوى بدل إظهاره كاملاً.
      singleLine = true,
      maxLines = 1,
      ellipsize = "end",
      paddingRight = "6dp",
      paddingLeft = "6dp",
      paddingTop = "8dp",
      paddingBottom = "8dp",
      layout_width = "0dp",
      layout_weight = "1",
      layout_height = "wrap_content",
      typeface = Typeface.DEFAULT
    },
    {
      View,
      backgroundColor = WHITE_LINE,
      layout_width = "2dp",
      layout_height = "match_parent",
      layout_marginTop = "4dp",
      layout_marginBottom = "4dp"
    }
  }
}
local function getStyledAdapter(data)
  local listData = {}
  for _, v in ipairs(data or {}) do
    local strVal = tostring(v or "")
    local line1 = strVal
    table.insert(listData, {
      itemRoot = { backgroundColor = BLUE_BG },
      title = {
        text = line1,
        contentDescription = strVal
      }
    })
  end
  return LuaAdapter(service, listData, grid_item_layout)
end
local function focusAndShowKeyboard(editText)
  if editText then
    editText.requestFocus()
    local imm = service.getSystemService(Context.INPUT_METHOD_SERVICE)
    if imm then
      imm.showSoftInput(editText, 0)
    end
  end
end
local function hideKeyboard(editText)
  if editText then
    local imm = service.getSystemService(Context.INPUT_METHOD_SERVICE)
    if imm then
      imm.hideSoftInputFromWindow(editText.getWindowToken(), 0)
    end
  end
end
local function setupTitleLimiter(editText)
  if editText then
    local isUpdating = false
    editText.addTextChangedListener(TextWatcher({
      onTextChanged = function(s)
        if isUpdating then return end
        local textStr = tostring(s or "")
        local lengthCheck = (utf8 and utf8.len(textStr)) or #textStr
        if lengthCheck > 40 then
          isUpdating = true
          local clipped = ""
          if utf8 and utf8.len(textStr) then
            local count = 0
            for _, codepoint in utf8.codes(textStr) do
              count = count + 1
              if count > 40 then break end
              clipped = clipped .. utf8.char(codepoint)
            end
          else
            clipped = textStr:sub(1, 40)
          end
          editText.setText(clipped)
          pcall(function()
            local newLen = string.len(clipped)
            local currentTextLen = editText.getText() and editText.getText().length and editText.getText():length() or newLen
            if newLen <= currentTextLen then
              editText.setSelection(newLen)
            end
          end)
          isUpdating = false
          speakDelayed(L("titleLimitMsg"))
        end
      end
    }))
  end
end
-- سجل مركزي لنوافذ المذكرة، لأن فتح المذكرة مرة أخرى مقصود أن
-- ينشئ طبقة جديدة فوق السابقة، وتغلق ضغطة الرجوع الطبقة الحالية
-- فقط، ثم تكشف الطبقة التي تحتها.
local memoDialogRegistry = memoDialogRegistry or {}
local function removeMemoDialogFromRegistry(dlg)
  for i = #memoDialogRegistry, 1, -1 do
    if memoDialogRegistry[i] == dlg then
      table.remove(memoDialogRegistry, i)
      break
    end
  end
end
local function getTopMemoDialog()
  return memoDialogRegistry[#memoDialogRegistry]
end
function farouqTi1()
  playSafeTone(ToneGenerator.TONE_CDMA_NETWORK_USA_RINGBACK, 200)
  local updateInterfaceTexts
  local function updateDialogHeightDynamic(dlg, count, widthPercent, columnsOverride)
    task(50, function()
      pcall(function()
        if not dlg then return end
        local window = dlg.getWindow()
        if not window then return end
        local dm = service.getResources().getDisplayMetrics()
        local screenWidth = dm.widthPixels
        local screenHeight = dm.heightPixels
        local maxHeight = math.floor(screenHeight * 0.95)
        local widthRatio = tonumber(widthPercent) or 1
        if widthRatio <= 0 or widthRatio > 1 then widthRatio = 1 end
        local finalWidth = math.floor(screenWidth * widthRatio)

        window.setGravity(Gravity.CENTER)

        if tonumber(count) <= 2 then
          -- عند الفراغ أو وجود عنصر/عنصرين فقط: اجعل الواجهة في
          -- نفس نطاق حجمها المنكمش، ثم زد الارتفاع الفعلي 2% فقط.
          -- هذا يمنع اختفاء العنصر الأول أو الثاني، مع بقاء العرض 95%.
          window.setLayout(finalWidth, WindowManager.LayoutParams.WRAP_CONTENT)
          window.getDecorView().post(function()
            pcall(function()
              local currentHeight = window.getDecorView().getHeight() or 0
              local collapsedHeight = currentHeight > 0 and math.floor(currentHeight * 1.02)
                or math.floor(screenHeight * 0.02)
              window.setLayout(finalWidth, math.max(1, collapsedHeight))
              window.setGravity(Gravity.CENTER)
            end)
          end)
          return
        end

        local columns = tonumber(columnsOverride) or tonumber(currentColumns) or 1
        if columns < 1 then columns = 1 end
        local rows = math.ceil((tonumber(count) or 0) / columns)
        local density = dm.density
        local estimatedRowHeight = math.floor(65 * density)
        local fixedHeaderFooterHeight = math.floor(180 * density)
        local totalHeight = (rows * estimatedRowHeight) + fixedHeaderFooterHeight
        local finalHeight = math.min(totalHeight, maxHeight)

        window.setLayout(finalWidth, finalHeight)
        window.getDecorView().post(function()
          pcall(function() window.setGravity(Gravity.CENTER) end)
        end)
      end)
    end)
  end
  local refreshMemoAfterImport
  local refreshManageAfterDataChange
  local function previewPickerText(value)
    -- اعرض السطر الأول كاملًا، واترك TextView يختصره تلقائيًا
    -- حسب العرض الحقيقي للشاشة بدل قصه إلى عدد ثابت من الأحرف.
    local str = tostring(value or "")
    str = str:gsub("\r", "")
    str = str:match("^([^\n]*)") or str
    return str:gsub("^%s+", ""):gsub("%s+$", "")
  end
  local function showSingleLinePicker(dialogTitle, rawItems, targetEditText)
    rawItems = rawItems or {}
    local selectedMap = {}
    local displayData = {}
    local function rebuildPickerDisplay()
      for i = #displayData, 1, -1 do
        table.remove(displayData, i)
      end
      for idx, fullText in ipairs(rawItems) do
        local strFull = tostring(fullText or "")
        local line1 = previewPickerText(strFull)
        local isSel = selectedMap[idx] or false
        table.insert(displayData, {
          rowContainer = { backgroundColor = isSel and SELECTION_BLUE or BLUE_BG },
          line_text = {
            text = (isSel and "✓ " or "") .. line1,
            backgroundColor = isSel and SELECTION_BLUE or 0xFF111111,
            contentDescription = (isSel and L("selectedPrefix") or "") .. strFull
          },
          rowDivider = {
            backgroundColor = isSel and SELECTION_BLUE or 0xFF555555
          }
        })
      end
    end
    rebuildPickerDisplay()
    local compactRowLayout = {
      LinearLayout,
      id = "rowContainer",
      orientation = "vertical",
      backgroundColor = 0xFF444444,
      layout_width = "match_parent",
      layout_height = "wrap_content",
      gravity = "center",
      paddingLeft = "6dp",
      paddingRight = "6dp",
      paddingTop = "7dp",
      paddingBottom = "7dp",
      {
        TextView,
        id = "line_text",
        textColor = TEXT_COLOR,
        textSize = "20sp",
        backgroundColor = 0xFF111111,
        gravity = "center",
        textAlignment = "center",
        singleLine = true,
        ellipsize = "end",
        paddingLeft = "2dp",
        paddingRight = "2dp",
        paddingTop = "7dp",
        paddingBottom = "7dp",
        layout_width = "match_parent",
        layout_height = "wrap_content",
        includeFontPadding = true
      },
      {
        LinearLayout,
        id = "rowDivider",
        backgroundColor = 0xFF555555,
        layout_width = "match_parent",
        layout_height = "1dp"
      }
    }
    local pickerLayout = {
      LinearLayout,
      orientation = "vertical",
      backgroundColor = BLUE_BG,
      layout_width = "match_parent",
      layout_height = "match_parent",
      {
        TextView,
        text = dialogTitle,
        textColor = TEXT_COLOR,
        textSize = responsiveSp(dialogTitle, 35, 24, 16),
        singleLine = true,
        ellipsize = "end",
        backgroundColor = DARK_BLUE_TITLE,
        gravity = "center",
        padding = "6dp",
        typeface = Typeface.create("sans-serif", Typeface.NORMAL),
        layout_width = "96%w",
        layout_height = "wrap_content",
        typeface = Typeface.DEFAULT
      },
      {
        ListView,
        id = "pickerList",
        paddingLeft = "0dp",
        paddingRight = "0dp",
        layout_width = "match_parent",
        layout_height = "0dp",
        layout_weight = "1",
        divider = nil
      },
      {
        Button,
        id = "btnPickerCancel",
        text = L("cancel"),
        contentDescription = L("cancel"),
        textColor = TEXT_COLOR,
        textSize = "15sp",
        backgroundColor = BUTTON_BLUE,
        layout_width = "match_parent",
        layout_height = "wrap_content",
        padding = "10dp"
      }
    }
    local dlg = LuaDialog(service)
    dlg.View = loadlayout(pickerLayout)
    local adapter = LuaAdapter(service, displayData, compactRowLayout)
    _G.pickerList.adapter = adapter
    _G.pickerList.onItemClick = function(parent, view, position, id)
      playSafeTone(ToneGenerator.TONE_CDMA_KEYPAD_VOLUME_KEY_LITE, 100)
      selectedMap = {}
      selectedMap[position + 1] = true
      rebuildPickerDisplay()
      pcall(function() adapter.notifyDataSetChanged() end)
      local fullSelectedText = rawItems[position + 1]
      if targetEditText and fullSelectedText then
        local currentText = tostring(targetEditText.getText() or "")
        if currentText == "" then
          targetEditText.setText(fullSelectedText)
        else
          targetEditText.setText(currentText .. "\n" .. fullSelectedText)
        end
      end
      dlg.dismiss()
    end
    _G.btnPickerCancel.onClick = function()
      playSafeTone(ToneGenerator.TONE_CDMA_LOW_PBX_L, 120)
      dlg.dismiss()
    end
    dlg.setOnKeyListener(function(dialog, keyCode, event)
      if keyCode == KeyEvent.KEYCODE_BACK and event.getAction() == KeyEvent.ACTION_UP then
        dlg.dismiss()
        return true
      end
      return false
    end)
    dlg.show()
    updateDialogHeightDynamic(dlg, #rawItems, 0.95, 1)
    pcall(function()
      _G.pickerList.setVerticalScrollBarEnabled(true)
      _G.pickerList.setScrollbarFadingEnabled(false)
      _G.pickerList.setSmoothScrollbarEnabled(true)
      _G.pickerList.setOverScrollMode(View.OVER_SCROLL_ALWAYS)
    end)
  end
  local function showImportSingleLinePicker(dialogTitle, rawItems, isFavorite, sourceType, parentDlg)
    if isFavorite then
      playFavTone()
    else
      playClipTone()
    end
    if #rawItems == 0 then
      local emptyMessage
      if sourceType == "deviceClip" then
        emptyMessage = L("emptyDeviceClipMsg")
      else
        emptyMessage = isFavorite and L("emptyFavMsg") or L("emptyClipMsg")
      end
      speakDelayed(emptyMessage)
      if sourceType ~= "deviceClip" then
        return
      end
    end
    local selectedMap = {}
    local displayData = {}
    local function rebuildDisplayData()
      for i = #displayData, 1, -1 do
        table.remove(displayData, i)
      end
      for idx, fullText in ipairs(rawItems) do
        local strFull = tostring(fullText or "")
        local line1 = previewPickerText(strFull)
        local isSel = selectedMap[idx] or false
        table.insert(displayData, {
          rowContainer = {
            backgroundColor = isSel and SELECTION_BLUE or BLUE_BG
          },
          line_text = {
            text = (isSel and "✓ " or "") .. line1,
            backgroundColor = isSel and SELECTION_BLUE or 0xFF111111,
            contentDescription = (isSel and L("selectedPrefix") or "") .. strFull
          },
          rowDivider = {
            backgroundColor = isSel and SELECTION_BLUE or 0xFF555555
          }
        })
      end
    end
    rebuildDisplayData()
    local compactRowLayout = {
      LinearLayout,
      id = "rowContainer",
      orientation = "vertical",
      backgroundColor = 0xFF444444,
      layout_width = "match_parent",
      layout_height = "wrap_content",
      gravity = "center",
      paddingLeft = "6dp",
      paddingRight = "6dp",
      paddingTop = "7dp",
      paddingBottom = "7dp",
      {
        TextView,
        id = "line_text",
        textColor = TEXT_COLOR,
        textSize = "20sp",
        backgroundColor = 0xFF111111,
        gravity = "center",
        textAlignment = "center",
        singleLine = true,
        ellipsize = "end",
        paddingLeft = "8dp",
        paddingRight = "8dp",
        paddingTop = "7dp",
        paddingBottom = "7dp",
        layout_width = "match_parent",
        layout_height = "wrap_content"
      },
      {
        LinearLayout,
        id = "rowDivider",
        backgroundColor = 0xFF555555,
        layout_width = "match_parent",
        layout_height = "1dp"
      }
    }
    local importBottomLayout = {
      LinearLayout,
      orientation = "horizontal",
      backgroundColor = BLUE_BG,
      layout_width = "match_parent",
      layout_height = "wrap_content",
      padding = "8dp"
    }
    table.insert(importBottomLayout, {Button,id="btnImportAll",text=L("importAll"),textColor=TEXT_COLOR,textSize="13sp",backgroundColor=GREEN_BG,layout_width="0dp",layout_height="wrap_content",layout_weight="1"})
    table.insert(importBottomLayout, {Button,id="btnJieshuoSelectAll",text=L("selectAll"),textColor=TEXT_COLOR,textSize="13sp",backgroundColor=BROWN_BTN,layout_width="0dp",layout_height="wrap_content",layout_weight="1"})
    table.insert(importBottomLayout, {Button,id="btnImportSelected",text=L("importSelected"),textColor=TEXT_COLOR,textSize="13sp",backgroundColor=GREEN_BG,layout_width="0dp",layout_height="wrap_content",layout_weight="1"})
    table.insert(importBottomLayout, {Button,id="btnFolderBackup",text=L("backup"),textColor=TEXT_COLOR,textSize="13sp",backgroundColor=GREEN_BG,layout_width="0dp",layout_height="wrap_content",layout_weight="1"})
    if sourceType == "deviceClip" then
      table.insert(importBottomLayout, {Button,id="btnFolderDelete",text=L("delete"),textColor=TEXT_COLOR,textSize="13sp",backgroundColor=DELETE_RED,layout_width="0dp",layout_height="wrap_content",layout_weight="1"})
    end
    table.insert(importBottomLayout, {Button,id="btnImportCancel",text=L("cancel"),textColor=TEXT_COLOR,textSize="13sp",backgroundColor=BANNER_RED,layout_width="0dp",layout_height="wrap_content",layout_weight="1"})
    local importDlgLayout = {
      LinearLayout,
      orientation = "vertical",
      backgroundColor = BLUE_BG,
      layout_width = "match_parent",
      layout_height = "match_parent",
      {
        TextView,
        id = "impDialogTitle",
        text = dialogTitle,
        textColor = TEXT_COLOR,
        textSize = responsiveSp(dialogTitle, 35, 24, 16),
        singleLine = true,
        ellipsize = "end",
        backgroundColor = DARK_BLUE_TITLE,
        gravity = "center",
        padding = "10dp",
        layout_width = "match_parent",
        layout_height = "wrap_content",
        typeface = Typeface.DEFAULT
      },
      {
        ListView,
        id = "impListView",
        paddingLeft = "0dp",
        paddingRight = "0dp",
        layout_width = "match_parent",
        layout_height = "0dp",
        layout_weight = "1",
        divider = nil
      },
      importBottomLayout
    }
local dlgImp = LuaDialog(service)
    dlgImp.View = loadlayout(importDlgLayout)
    dlgImp.setOnKeyListener(function(dialog, keyCode, event)
      if keyCode == KeyEvent.KEYCODE_BACK and event.getAction() == KeyEvent.ACTION_UP then
        dlgImp.dismiss()
        if parentDlg then
          parentDlg.show()
        end
        return true
      end
      return false
    end)
    local impAdapter = LuaAdapter(service, displayData, compactRowLayout)
    _G.impListView.adapter = impAdapter
    local isDeviceStore = (sourceType == "deviceClip")
    if isDeviceStore then
      _G.impDialogTitle.setText(L("deviceClipboardTitle") .. ": " .. #rawItems)
    end
    _G.btnFolderBackup.onClick = function()
      playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
      local backupKind
      if sourceType == "deviceClip" then
        backupKind = "deviceClipboard"
      elseif isFavorite then
        backupKind = "jieshuoFavorites"
      else
        backupKind = "jieshuoClipboard"
      end
      local backupIndex = backupIndexByKind[backupKind]
      local ok = backupIndex and writeBackupFile(
        backupFilesByIndex[backupIndex],
        backupNamesByIndex[backupIndex],
        rawItems
      ) or false
      speakDelayed(ok and string.format(L("backupSuccess"), #rawItems) or L("backupCreateFailed"))
    end
    if sourceType == "deviceClip" then
      _G.btnFolderDelete.onClick = function()
        playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
        local kept = {}
        local deleted = 0
        for i, value in ipairs(rawItems) do
          if selectedMap[i] then
            deleted = deleted + 1
          else
            kept[#kept + 1] = value
          end
        end
        if deleted == 0 then
          speakDelayed(L("selectToDelete"))
          return
        end
        local ok = writeDeviceStore(fDeviceClipboard, kept)
        if ok ~= false then
          rawItems = kept
          selectedMap = {}
          rebuildDisplayData()
          pcall(function() impAdapter.notifyDataSetChanged() end)
          _G.impDialogTitle.setText(dialogTitle:gsub(":%s*%d+%s*$", "") .. ": " .. #rawItems)
          updateDialogHeightDynamic(dlgImp, #rawItems, 0.95, 1)
          speakDelayed(string.format(L("deleteSelected"), deleted))
        else
          speakDelayed(L("deleteSelectedFailed"))
        end
      end
    end
    _G.impListView.onItemClick = function(parent, view, position, id)
      playSafeTone(ToneGenerator.TONE_CDMA_KEYPAD_VOLUME_KEY_LITE, 100)
      local idx = position + 1
      selectedMap[idx] = not selectedMap[idx]
      rebuildDisplayData()
      pcall(function() impAdapter.notifyDataSetChanged() end)
      updateDialogHeightDynamic(dlgImp, #rawItems, 0.95, 1)
      if isDeviceStore then
        local allSelectedNow = (#rawItems > 0)
        for i = 1, #rawItems do