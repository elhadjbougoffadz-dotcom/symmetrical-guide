local layout = {
    LinearLayout,
    orientation = "vertical",
    backgroundColor = BLUE_BG,
    layout_width = "match_parent",
    layout_height = "match_parent",
    {
      TextView,
      id = "textview",
      text = L("memoHeader"),
      textColor = TEXT_COLOR,
      textSize = responsiveLatinSp(L("memoHeader"), 40, 22, 14, currentLang == "fr" and 4 or 2),
      singleLine = true,
      ellipsize = "end",
      backgroundColor = DARK_BLUE_TITLE,
      gravity = "center",
      layout_width = "match_parent",
      layout_height = "wrap_content",
      padding = "16dp",
      typeface = Typeface.DEFAULT
    },
    {
      LinearLayout,
      orientation = "vertical",
      layout_width = "match_parent",
      layout_height = "wrap_content",
      backgroundColor = BLUE_BG,
      padding = "4dp",
      {
        Button,
        id = "btnToggleMode",
        text = L("searchToggleTitle3"),
        textColor = TEXT_COLOR,
        textSize = "13.13sp",
        backgroundColor = BANNER_RED,
        layout_width = "match_parent",
        layout_height = "wrap_content",
        layout_marginBottom = "4dp"
      },{
        EditText,
        id = "searchEdit",
        hint = L("searchHintTitles"),
        textColor = TEXT_COLOR,
        hintTextColor = TEXT_COLOR,
        layout_width = "match_parent",
        layout_height = "wrap_content",
        backgroundColor = BANNER_RED,
        textSize = "20sp",
        gravity = "center",
        padding = "8dp",
        visibility = View.GONE
      },
      {
        Button,
        id = "btnNoResult",
        text = L("noResult"),
        textColor = TEXT_COLOR,
        textSize = "16.16sp",
        backgroundColor = BANNER_RED,
        layout_width = "match_parent",
        layout_height = "wrap_content",
        layout_marginTop = "6dp",
        visibility = View.GONE
      }
    },
    {
      FrameLayout,
      layout_width = "match_parent",
      layout_height = "0dp",
      layout_weight = "1",
      {
        GridView,
        id = "list",
        numColumns = currentColumns,
        layout_width = "match_parent",
        layout_height = "match_parent",
        padding = "0dp"
      },
      {
        TextView,
        id = "emptyMemo",
        text = L("memoEmpty"),
        textColor = 0xFFFFFFFF,
        textSize = responsiveLatinSp(L("memoEmpty"), 40, 22, 14),
        backgroundColor = 0xFF000000,
        gravity = "center",
        textAlignment = "center",
        layout_width = "match_parent",
        layout_height = "match_parent",
        visibility = View.GONE,
        typeface = Typeface.DEFAULT_BOLD
      }
    },
    {
      LinearLayout,
      orientation = "horizontal",
      backgroundColor = GREEN_BG,
      layout_width = "match_parent",
      layout_height = "wrap_content",
      padding = "4dp",
      {
        Button,
        id = "btnBottomAdd",
        text = L("addBtn"),
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
        id = "btnBottomSettings",
        text = L("settingsBtn"),
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
        id = "btnBottomExit",
        text = L("exitBtn"),
        textColor = TEXT_COLOR,
        textSize = "15sp",
        backgroundColor = BUTTON_BLUE,
        layout_width = "0dp",
        layout_height = "wrap_content",
        layout_weight = "1"
      }
    }
  }
  scj = LuaDialog(this)
  table.insert(memoDialogRegistry, scj)
  scj.View = loadlayout(layout)
  function updateEmptyMemoState(items)
    local isMemoEmpty = not hasMemoItems(items)
    if _G.emptyMemo then
      _G.emptyMemo.setVisibility(isMemoEmpty and View.VISIBLE or View.GONE)
    end
    if _G.list then
      _G.list.setVisibility(isMemoEmpty and View.GONE or View.VISIBLE)
    end
  end
  function refreshMemoView(dialog, items)
    currentList = items or {}
    local function applyMemoRefresh()
      pcall(function()
        updateEmptyMemoState(currentList)
        if _G.list then
          refreshListAdapterPreservePosition(_G.list, getStyledAdapter(currentList))
        end
        updateMainDialogPosition(dialog, currentList)
        updateDialogHeightDynamic(dialog, #currentList, 0.95, 1)
        applyMainDialogConstraints(dialog, #t1 > 0)
        updateInterfaceTexts()
        -- لا تعيد إظهار نافذة قديمة بعد أن أُغلقت أو استُبدلت بنافذة جديدة.
        if dialog and dialog.show and scj == dialog then dialog.show() end
      end)
    end
    -- تحديث فوري ومتكرر بعد آخر إضافة أو حذف لضمان ثبات الحجم والتمركز.
    applyMemoRefresh()
    task(80, applyMemoRefresh)
    task(220, applyMemoRefresh)
    task(450, applyMemoRefresh)
  end
  local isKeyboardShown = false
  scj.setOnKeyListener(function(dialog, keyCode, event)
    if keyCode == KeyEvent.KEYCODE_BACK and event.getAction() == KeyEvent.ACTION_UP then
      -- الرجوع الأول أثناء البحث: أخفِ لوحة المفاتيح فقط، ولا تغلق المذكرة.
      if isKeyboardShown then
        -- عند الضغط على الرجوع أثناء البحث: أغلق لوحة المفاتيح،
        -- أعد البحث إلى العناوين، وأخفِ مربع الكتابة فورًا.
        hideKeyboard(_G.searchEdit)
        isKeyboardShown = false
        searchStage = 3
        searchMode = "titles"
        currentList = t1
        if _G.btnToggleMode then
          _G.btnToggleMode.setText(L("searchToggleTitle3"))
          _G.btnToggleMode.setContentDescription(L("searchToggleTitle3"))
        end
        if _G.searchEdit then
          _G.searchEdit.clearFocus()
          _G.searchEdit.setText("")
          _G.searchEdit.setHint(L("searchHintTitles"))
          _G.searchEdit.setVisibility(View.GONE)
        end
        if _G.btnNoResult then _G.btnNoResult.setVisibility(View.GONE) end
        refreshListAdapterPreservePosition(_G.list, getStyledAdapter(t1))
        if scj then
          scj.show()
          updateMainDialogPosition(scj, t1)
          updateDialogHeightDynamic(scj, #t1, 0.95, 1)
        end
        pcall(function() updateInterfaceTexts() end)
        return true
      end
      -- إذا كانت هناك عدة نوافذ مذكرة متراكمة، يغلق الرجوع النافذة
      -- الحالية فقط. الضغطة التالية تغلق التي تحتها، وهكذا، حتى
      -- تختفي آخر نافذة. وإذا كانت واحدة فقط، تختفي مباشرة.
      local closingDialog = dialog or scj
      pcall(function()
        hideKeyboard(_G.searchEdit)
        if _G.searchEdit then
          _G.searchEdit.clearFocus()
          _G.searchEdit.setVisibility(View.GONE)
        end
      end)
      pcall(function()
        if closingDialog then closingDialog.dismiss() end
      end)
      removeMemoDialogFromRegistry(closingDialog)
      scj = getTopMemoDialog()
      return true
    end
    return false
  end)
  local btnToggleMode = _G.btnToggleMode
  local searchEdit = _G.searchEdit
  local btnNoResult = _G.btnNoResult
  local openMemoStatsDialog
  openMemoStatsDialog = function(parentDlg)
    playSafeTone(ToneGenerator.TONE_CDMA_ABBR_ALERT, 180)
    local noteCount = #t1
    local clipCount = 0
    local favCount = 0
    local deviceClipCount = 0
    pcall(function()
      local listC = service.getClipboardList()
      clipCount = listC and (listC.size and listC.size() or #listC) or 0
    end)
    pcall(function()
      local listF = service.getFavoritesList()
      favCount = listF and (listF.size and listF.size() or #listF) or 0
    end)
    deviceClipCount = getDeviceCounts()
    local statsSpeech = L("statMemo") .. noteCount .. ", " ..
      L("statClip") .. clipCount .. ", " ..
      L("statFav") .. favCount .. ", " ..
      L("statDevice") .. deviceClipCount
    speakDelayed(statsSpeech)
    local dlgStats = LuaDialog(service)
    local function returnToParent()
      dlgStats.dismiss()
      if parentDlg then
        parentDlg.show()
      end
    end
    dlgStats.setOnKeyListener(function(dialog, keyCode, event)
      if keyCode == KeyEvent.KEYCODE_BACK and event.getAction() == KeyEvent.ACTION_UP then
        returnToParent()
        return true
      end
      return false
    end)
    local statsLayout = {
      LinearLayout,
      orientation = "vertical",
      backgroundColor = BLUE_BG,
      layout_width = "match_parent",
      layout_height = "wrap_content",
      {
        TextView,
        text = L("memoStats"),
        textColor = TEXT_COLOR,
        textSize = responsiveSp(L("memoStats"), 35, 24, 16),
        singleLine = true,
        ellipsize = "end",
        backgroundColor = DARK_BLUE_TITLE,
        gravity = "center",
        padding = "10dp",
        layout_width = "match_parent",
        typeface = Typeface.DEFAULT
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
          id = "btnStatMemo",
          text = L("statMemo") .. noteCount,
          contentDescription = L("statMemo") .. noteCount,
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
          id = "btnStatClip",
          text = L("statClip") .. clipCount,
          contentDescription = L("statClip") .. clipCount,
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
          id = "btnStatFav",
          text = L("statFav") .. favCount,
          contentDescription = L("statFav") .. favCount,
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
          id = "btnStatDeviceClip",
          text = L("statDevice") .. deviceClipCount,
          contentDescription = L("statDevice") .. deviceClipCount,
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
          id = "btnStatClose",
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
    dlgStats.View = loadlayout(statsLayout)
    dlgStats.show()
    _G.btnStatMemo.onClick = function()
      playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
      speakDelayed(L("statMemo") .. noteCount)
    end
    _G.btnStatClip.onClick = function()
      playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
      speakDelayed(L("statClip") .. clipCount)
    end
    _G.btnStatFav.onClick = function()
      playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
      speakDelayed(L("statFav") .. favCount)
    end
    _G.btnStatDeviceClip.onClick = function()
      playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
      speakDelayed(L("statDevice") .. deviceClipCount)
    end
    _G.btnStatClose.onClick = function()
      playSafeTone(ToneGenerator.TONE_CDMA_LOW_PBX_L, 120)
      returnToParent()
    end
  end
  _G.textview.onClick = function()
    playSafeTone(ToneGenerator.TONE_CDMA_ABBR_ALERT, 180)
    local noteCount = #t1
    local clipCount = 0
    local favCount = 0
    local deviceClipCount = 0
    pcall(function()
      local listC = service.getClipboardList()
      clipCount = listC and (listC.size and listC.size() or #listC) or 0
    end)
    pcall(function()
      local listF = service.getFavoritesList()
      favCount = listF and (listF.size and listF.size() or #listF) or 0
    end)
    deviceClipCount = getDeviceCounts()
    speakDelayed(
      L("statMemo") .. noteCount .. ", " ..
      L("statClip") .. clipCount .. ", " ..
      L("statFav") .. favCount .. ", " ..
      L("statDevice") .. deviceClipCount
    )
  end
  _G.btnBottomExit.onClick = function()
    playSafeTone(ToneGenerator.TONE_CDMA_LOW_PBX_L, 120)
    scj.dismiss()
    service.stopSelf()
  end
  _G.btnBottomSettings.onClick = function()
    playSafeTone(ToneGenerator.TONE_PROP_BEEP, 120)
    local dlgSettings = LuaDialog(service)
    dlgSettings.setOnKeyListener(function(dialog, keyCode, event)
      if keyCode == KeyEvent.KEYCODE_BACK and event.getAction() == KeyEvent.ACTION_UP then
        dlgSettings.dismiss()
        if scj then scj.show() end
        return true
      end
      return false
    end)
    local settingsLayout = {LinearLayout,
      orientation = "vertical",
      backgroundColor = BLUE_BG,
      layout_width = "match_parent",
      layout_height = "wrap_content",
      padding = "0dp",
      {
        TextView,
        text = L("settingsTitle"),
        textColor = TEXT_COLOR,
        textSize = responsiveSp(L("settingsTitle"), 35, 28, 16),
        singleLine = true,
        ellipsize = "end",
        backgroundColor = DARK_BLUE_TITLE,
        gravity = "center",
        padding = "6dp",
        typeface = Typeface.create("sans-serif", Typeface.NORMAL),
        layout_width = "96%w"
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
          id = "btnSettingsManage",
          text = L("manageItems"),
          textColor = TEXT_COLOR,
          textSize = responsiveSp(L("manageItems"), 20, 16, 18),
          backgroundColor = GREEN_BG,
          layout_width = "match_parent",
          layout_height = "wrap_content",
          layout_marginBottom = "8dp",
          padding = "10dp"
        },
        {
          Button,
          id = "btnChangeColumns",
          text = L("changeColumns"),
          textColor = TEXT_COLOR,
          textSize = responsiveSp(L("changeColumns"), 20, 16, 18),
          backgroundColor = GREEN_BG,
          layout_width = "match_parent",
          layout_height = "wrap_content",
          layout_marginBottom = "8dp",
          padding = "10dp"
        },
        {
          Button,
          id = "btnChangeLang",
          text = L("changeLang"),
          textColor = TEXT_COLOR,
          textSize = responsiveSp(L("changeLang"), 20, 16, 18),
          backgroundColor = GREEN_BG,
          layout_width = "match_parent",
          layout_height = "wrap_content",
          layout_marginBottom = "8dp",
          padding = "10dp"
        },
        {
          Button,
          id = "btnMemoStats",
          text = L("memoStats"),
          textColor = TEXT_COLOR,
          textSize = responsiveSp(L("memoStats"), 20, 16, 18),
          backgroundColor = GREEN_BG,
          layout_width = "match_parent",
          layout_height = "wrap_content",
          layout_marginBottom = "8dp",
          padding = "10dp"
        },
        {
          Button,
          id = "btnBackupRestore",
          text = L("backupRestore"),
          textColor = TEXT_COLOR,
          textSize = responsiveSp(L("backupRestore"), 20, 15, 18),
          backgroundColor = GREEN_BG,
          layout_width = "match_parent",
          layout_height = "wrap_content",
          layout_marginBottom = "8dp",
          padding = "10dp"
        },
        {
          Button,
          id = "btnMoreInfo",
          text = L("moreInfo"),
          textColor = TEXT_COLOR,
          textSize = responsiveSp(L("moreInfo"), 20, 16, 18),
          backgroundColor = GREEN_BG,
          layout_width = "match_parent",
          layout_height = "wrap_content",
          padding = "10dp"
        },
        {
          Button,
          id = "btnSettingsCancel",
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
    dlgSettings.View = loadlayout(settingsLayout)

    _G.btnSettingsCancel.onClick = function()
      playSafeTone(ToneGenerator.TONE_CDMA_LOW_PBX_L, 120)
      dlgSettings.dismiss()
      if scj and scj.show then scj.show() end
    end
    _G.btnSettingsManage.onClick = function()
      playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
      dlgSettings.dismiss()
      openManageDialog(dlgSettings)
    end
    _G.btnMemoStats.onClick = function()
      dlgSettings.dismiss()
      if scj and scj.dismiss then scj.dismiss() end
      openMemoStatsDialog(dlgSettings)
    end
    _G.btnBackupRestore.onClick = function()
      playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
      dlgSettings.dismiss()
      local dlgBR = LuaDialog(service)
      local brLayout = {
        LinearLayout,
        orientation = "vertical",
        backgroundColor = BLUE_BG,
        layout_width = "match_parent",
        layout_height = "wrap_content",
        {
          TextView,
          text = L("backupRestore"),
          textColor = TEXT_COLOR,
          textSize = responsiveSp(L("backupRestore"), 35, 27, 16),
          singleLine = true,
          ellipsize = "end",
          backgroundColor = DARK_BLUE_TITLE,
          gravity = "center",
          padding = "10dp",
          layout_width = "match_parent",
          typeface = Typeface.DEFAULT
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
            id = "btnCreateBackup",
            text = L("createBackup"),
            textColor = TEXT_COLOR,
            textSize = responsiveSp(L("createBackup"), 20, 15, 18),
            backgroundColor = GREEN_BG,
            layout_width = "match_parent",
            layout_height = "wrap_content",
            layout_marginBottom = "8dp",
            padding = "10dp"
          },
          {
            Button,
            id = "btnRestoreBackup",
            text = L("restoreBackup"),
            textColor = TEXT_COLOR,
            textSize = responsiveSp(L("restoreBackup"), 20, 15, 18),
            backgroundColor = GREEN_BG,
            layout_width = "match_parent",
            layout_height = "wrap_content",
            layout_marginBottom = "8dp",
            padding = "10dp"
          },
          {
            Button,
            id = "btnBRCancel",
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
      dlgBR.View = loadlayout(brLayout)
      dlgBR.show()
      dlgBR.setOnKeyListener(function(dialog, keyCode, event)
        if keyCode == KeyEvent.KEYCODE_BACK and event.getAction() == KeyEvent.ACTION_UP then
          dlgBR.dismiss()
          pcall(function()
      local window = dlgSettings.getWindow()
      if window then window.setGravity(Gravity.CENTER) end
    end)
    dlgSettings.show()
          return true
        end
        return false
      end)
      local function copyJieshuoClipboard()
        local items = {}
        pcall(function()
          local c = service.getClipboardList()
          if c then
            local len = c.size and c.size() or #c
            for i = 0, len - 1 do
              table.insert(items, tostring(c[i] or ""))
            end
          end
        end)
        return items
      end
      local function copyJieshuoFavorites()
        local items = {}
        pcall(function()
          local f = service.getFavoritesList()
          if f then
            local len = f.size and f.size() or #f
            for i = 0, len - 1 do
              table.insert(items, tostring(f[i] or ""))
            end
          end
        end)
        return items
      end
      local function restoreJieshuoClipboard(items)
        local success = true
        local restoredCount = 0
        pcall(function()
          if service.clearClipboard then
            service.clearClipboard()
          end
        end)
        if not service.copy then
          return false, 0
        end
        for i = 1, #(items or {}) do
          local value = items[i]
          local ok = pcall(function()
            service.copy(tostring(value or ""))
          end)
          if ok then
            restoredCount = restoredCount + 1
          else
            success = false
          end
        end
        return success, restoredCount
      end
      local function restoreJieshuoFavorites(items)
        local success = true
        local restoredCount = 0
        pcall(function()
          if service.clearFavorites then
            service.clearFavorites()
          end
        end)
        if not service.addFavorites then
          return false, 0
        end
        for i = 1, #(items or {}) do
          local value = items[i]
          local ok = pcall(function()
            service.addFavorites(tostring(value or ""))
          end)
          if ok then
            restoredCount = restoredCount + 1
          else
            success = false
          end
        end
        return success, restoredCount
      end
      local function getBackupDataForIndex(index)
        if index == 1 then
          return {titles=t1 or {}, content=t2 or {}}
        elseif index == 2 then
          return copyJieshuoClipboard()