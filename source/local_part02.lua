        elseif index == 3 then
          return copyJieshuoFavorites()
        elseif index == 4 then
          return getDeviceClipboardList() or {}
        end
        return {}
      end
      local function saveOneBackup(index)
        local data = getBackupDataForIndex(index)
        return writeBackupFile(backupFilesByIndex[index], backupNamesByIndex[index], data)
      end
      -- عند الاستيراد نعرض عدد العناصر المحفوظة فعليًا داخل ملف النسخة الاحتياطية
      -- وليس عدد العناصر الموجودة حاليًا في المذكرة أو الحافظة على الجهاز.
      local function getStoredBackupCount(index)
        local ok, data = readBackupFile(backupFilesByIndex[index], backupNamesByIndex[index])
        if not ok then
          return 0
        end
        if index == 1 then
          if type(data) ~= "table" or type(data.titles) ~= "table" then
            return 0
          end
          return #data.titles
        elseif type(data) == "table" then
          return #data
        end
        return 0
      end
      local function restoreOneBackup(index)
        local ok, data = readBackupFile(backupFilesByIndex[index], backupNamesByIndex[index])
        if not ok then
          return false, "missing"
        end
        if index == 1 then
          if type(data.titles) ~= "table" or type(data.content) ~= "table" then
            return false, "invalid"
          end
          t1 = {}
          t2 = {}
          for i, value in ipairs(data.titles) do
            t1[i] = tostring(value or "")
          end
          for i, value in ipairs(data.content) do
            t2[i] = tostring(value or "")
          end
          f1:write(t1)
          f2:write(t2)
          currentList = (searchMode == "titles") and t1 or t2
          refreshMemoView(scj, currentList)
          return true, "ok"
        elseif index == 2 then
          if type(data) ~= "table" then return false, "invalid" end
          local ok, count = restoreJieshuoClipboard(data)
          return ok, ok and "ok:" .. tostring(count) or "invalid"
        elseif index == 3 then
          if type(data) ~= "table" then return false, "invalid" end
          local ok, count = restoreJieshuoFavorites(data)
          return ok, ok and "ok:" .. tostring(count) or "invalid"
        elseif index == 4 then
          if type(data) ~= "table" then return false, "invalid" end
          writeDeviceStore(fDeviceClipboard, data)
          return true, "ok"
        end
        return false, "invalid"
      end
      local function openBackupSelectionDialog(isRestore)
        local dlgSelect = LuaDialog(service)
        local selected = {false, false, false, false}
        local labelKeys = {"backupMemo", "backupJieshuoClipboard", "backupJieshuoFavorites", "backupDeviceClipboard"}
        local labels = {L(labelKeys[1]), L(labelKeys[2]), L(labelKeys[3]), L(labelKeys[4])}
        local ids = {"selMemo", "selJClip", "selJFav", "selDClip"}
        -- التصدير يعرض عدد العناصر الحالية التي سيتم حفظها،
        -- والاستيراد يعرض عدد العناصر الموجودة فعليًا داخل النسخ الاحتياطية على الجهاز.
        local counts
        if isRestore then
          counts = {
            getStoredBackupCount(1),
            getStoredBackupCount(2),
            getStoredBackupCount(3),
            getStoredBackupCount(4)
          }
        else
          counts = {
            #t1,
            #copyJieshuoClipboard(),
            #copyJieshuoFavorites(),
            #getDeviceClipboardList()
          }
        end
        local titleText = isRestore and L("restoreSelectTitle") or L("backupSelectTitle")
        local itemViews = {}
        for i = 1, 4 do
          itemViews[i] = {
            Button,
            id = ids[i],
            text = labels[i] .. ": " .. counts[i],
            contentDescription = labels[i] .. ": " .. counts[i],
            textColor = TEXT_COLOR,
            textSize = responsiveSp(labels[i] .. ": " .. counts[i], 20, 16, 18),
            backgroundColor = GREEN_BG,
            layout_width = "match_parent",
            layout_height = "wrap_content",
            layout_marginBottom = "8dp",
            padding = "10dp"
          }
        end
        local layout = {
          LinearLayout,
          orientation = "vertical",
          backgroundColor = BLUE_BG,
          layout_width = "match_parent",
          layout_height = "wrap_content",
          padding = "12dp",
          {
            TextView,
            text = titleText,
            textColor = TEXT_COLOR,
            textSize = responsiveSp(titleText, 35, 27, 16),
            backgroundColor = DARK_BLUE_TITLE,
            gravity = "center",
            padding = "10dp",
            layout_width = "match_parent",
            layout_height = "wrap_content"
          },
          itemViews[1], itemViews[2], itemViews[3], itemViews[4],
          {
            LinearLayout,
            orientation = "horizontal",
            backgroundColor = BLUE_BG,
            layout_width = "match_parent",
            layout_height = "wrap_content",
            {
              Button,
              id = "btnSelectAllBackup",
              text = L("selectAll"),
              contentDescription = L("selectAll"),
              textColor = TEXT_COLOR,
              textSize = "15sp",
              backgroundColor = GREEN_BG,
              layout_width = "0dp",
              layout_height = "wrap_content",
              layout_weight = "1",
              layout_marginRight = "4dp"
            },
            {
              Button,
              id = "btnDoneBackupSelection",
              text = L("done"),
              contentDescription = L("done"),
              textColor = TEXT_COLOR,
              textSize = "15sp",
              backgroundColor = BUTTON_BLUE,
              layout_width = "0dp",
              layout_height = "wrap_content",
              layout_weight = "1",
              layout_marginRight = "4dp"
            },
            {
              Button,
              id = "btnCancelBackupSelection",
              text = L("cancel"),
              contentDescription = L("cancel"),
              textColor = TEXT_COLOR,
              textSize = "15sp",
              backgroundColor = BANNER_RED,
              layout_width = "0dp",
              layout_height = "wrap_content",
              layout_weight = "1"
            }
          }
        }
        dlgSelect.View = loadlayout(layout)
        local function updateBackupSelectionColors()
          for i = 1, 4 do
            local btn = _G[ids[i]]
            if btn then
              btn.setBackgroundColor(selected[i] and 0xFF64B5F6 or GREEN_BG)
              btn.setText((selected[i] and "✓ " or "") .. labels[i] .. ": " .. counts[i])
            end
          end
        end
        local function speakSelectionState(index)
          if selected[index] then
            speakDelayed(L("selected"))
          else
            speakDelayed(L("unselected"))
          end
        end
        for i = 1, 4 do
          local index = i
          _G[ids[i]].onClick = function()
            selected[index] = not selected[index]
            playSafeTone(ToneGenerator.TONE_PROP_ACK, 100)
            updateBackupSelectionColors()
            speakSelectionState(index)
          end
        end
        _G.btnSelectAllBackup.onClick = function()
          local allSelected = true
          for i = 1, 4 do
            if not selected[i] then allSelected = false break end
          end
          for i = 1, 4 do selected[i] = not allSelected end
          playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
          updateBackupSelectionColors()
          if allSelected then
            speakDelayed(L("allDeselected"))
          else
            speakDelayed(L("allSelected"))
          end
        end
        updateBackupSelectionColors()
        dlgSelect.setOnKeyListener(function(dialog, keyCode, event)
          if keyCode == KeyEvent.KEYCODE_BACK and event.getAction() == KeyEvent.ACTION_UP then
            dlgSelect.dismiss()
            dlgBR.show()
            return true
          end
          return false
        end)
        local function showBackupConfirmation(confirmRestore)
          local dlgConfirmBackup = LuaDialog(service)
          local message
          if confirmRestore then
            message = L("restoreConfirmMessage")
          else
            message = L("backupConfirmMessage")
          end
          local confirmLayout = {
            LinearLayout,
            orientation = "vertical",
            backgroundColor = BLUE_BG,
            layout_width = "match_parent",
            layout_height = "wrap_content",
            padding = "12dp",
            {
              TextView,
              text = message,
              textColor = TEXT_COLOR,
              textSize = responsiveSp(message, 20, 15, 28),
              backgroundColor = DARK_BLUE_TITLE,
              gravity = "center",
              padding = "12dp",
              layout_width = "match_parent",
              layout_height = "wrap_content"
            },
            {
              LinearLayout,
              orientation = "horizontal",
              backgroundColor = BLUE_BG,
              layout_width = "match_parent",
              layout_height = "wrap_content",
              paddingTop = "10dp",
              {
                Button,
                id = "btnConfirmBackupCancel",
                text = L("cancel"),
                contentDescription = L("cancel"),
                textColor = TEXT_COLOR,
                textSize = "15sp",
                backgroundColor = BUTTON_BLUE,
                layout_width = "0dp",
                layout_height = "wrap_content",
                layout_weight = "1",
                layout_marginRight = "4dp"
              },
              {
                Button,
                id = "btnConfirmBackupDone",
                text = L("done"),
                contentDescription = L("done"),
                textColor = TEXT_COLOR,
                textSize = "15sp",
                backgroundColor = GREEN_BG,
                layout_width = "0dp",
                layout_height = "wrap_content",
                layout_weight = "1"
              }
            }
          }
          dlgConfirmBackup.View = loadlayout(confirmLayout)
          dlgConfirmBackup.setOnKeyListener(function(dialog, keyCode, event)
            if keyCode == KeyEvent.KEYCODE_BACK and event.getAction() == KeyEvent.ACTION_UP then
              dlgConfirmBackup.dismiss()
              dlgSelect.show()
              return true
            end
            return false
          end)
          _G.btnConfirmBackupCancel.onClick = function()
            playSafeTone(ToneGenerator.TONE_CDMA_LOW_PBX_L, 120)
            dlgConfirmBackup.dismiss()
            dlgSelect.show()
          end
          _G.btnConfirmBackupDone.onClick = function()
            playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
            dlgConfirmBackup.dismiss()
            if not confirmRestore then
              local successCount = 0
              local failedCount = 0
              for i = 1, 4 do
                if selected[i] then
                  if saveOneBackup(i) then
                    successCount = successCount + 1
                  else
                    failedCount = failedCount + 1
                  end
                end
              end
              if failedCount == 0 and successCount > 0 then
                speakDelayed(string.format(L("backupCreated"), successCount))
              elseif successCount > 0 then
                speakDelayed(string.format(L("backupPartial"), successCount, failedCount))
              else
                speakDelayed(L("backupFailed"))
              end
              dlgBR.show()
            else
              local successCount = 0
              local missingCount = 0
              local invalidCount = 0
              for i = 1, 4 do
                if selected[i] then
                  local ok, reason = restoreOneBackup(i)
                  if ok then
                    successCount = successCount + 1
                  elseif reason == "missing" then
                    missingCount = missingCount + 1
                  else
                    invalidCount = invalidCount + 1
                  end
                end
              end
              if successCount > 0 and missingCount == 0 and invalidCount == 0 then
                speakDelayed(string.format(L("restoreDone"), successCount))
              elseif successCount > 0 then
                speakDelayed(string.format(L("restorePartial"), successCount, missingCount, invalidCount))
              else
                speakDelayed(L("restoreFailed"))
              end
              dlgBR.show()
            end
          end
          dlgConfirmBackup.show()
        end
        _G.btnDoneBackupSelection.onClick = function()
          playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
          local anySelected = false
          for i = 1, 4 do
            if selected[i] then
              anySelected = true
              break
            end
          end
          if not anySelected then
            speakDelayed(L("noSelection"))
            return
          end
          dlgSelect.dismiss()
          showBackupConfirmation(isRestore)
        end
        _G.btnCancelBackupSelection.onClick = function()
          playSafeTone(ToneGenerator.TONE_CDMA_LOW_PBX_L, 120)
          dlgSelect.dismiss()
          dlgBR.show()
        end
        dlgSelect.show()
        updateDialogHeightDynamic(dlgSelect, 4, 0.95, 1)
      end
      _G.btnCreateBackup.onClick = function()
        playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
        dlgBR.dismiss()
        openBackupSelectionDialog(false)
      end
      _G.btnRestoreBackup.onClick = function()
        playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
        dlgBR.dismiss()
        openBackupSelectionDialog(true)
      end
      _G.btnBRCancel.onClick = function()
        playSafeTone(ToneGenerator.TONE_CDMA_LOW_PBX_L, 120)
        dlgBR.dismiss()
        dlgSettings.show()
      end
    end
_G.btnMoreInfo.onClick = function()
      playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
      dlgSettings.dismiss()
      if scj and scj.show then scj.show() end
      speakDelayed(L("appName") .. " - " .. L("enhancedDescription"))
    end
    _G.btnChangeLang.onClick = function()
      playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
      dlgSettings.dismiss()
      local dlgLang = LuaDialog(service)
      local function returnToSettings()
        dlgLang.dismiss()
        dlgSettings.show()
      end
      dlgLang.setOnKeyListener(function(dialog, keyCode, event)
        if keyCode == KeyEvent.KEYCODE_BACK and event.getAction() == KeyEvent.ACTION_UP then
          returnToSettings()
          return true
        end
        return false
      end)
      local arText = (currentLang == "ar") and ("✓ " .. L("langAr")) or L("langAr")
      local frText = (currentLang == "fr") and ("✓ " .. L("langFr")) or L("langFr")
      local enText = (currentLang == "en") and ("✓ " .. L("langEn")) or L("langEn")
      local langLayout = {
        LinearLayout,
        orientation = "vertical",
        backgroundColor = BLUE_BG,
        layout_width = "match_parent",
        layout_height = "wrap_content",
        {
          TextView,
          text = L("selectLangTitle"),
          textColor = TEXT_COLOR,
          textSize = responsiveSp(L("selectLangTitle"), 35, 28, 16),
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
          padding = "10dp",
          {
            Button,
            id = "langArabic",
            text = arText,
            contentDescription = L("langAr") .. (currentLang == "ar" and ", " .. L("languageSelected") or ""),
            textColor = TEXT_COLOR,
            textSize = responsiveSp(arText, 20, 16, 18),
            backgroundColor = GREEN_BG,
            layout_width = "match_parent",
            layout_height = "wrap_content",
            layout_marginBottom = "8dp"
          },
          {
            Button,
            id = "langFrench",
            text = frText,
            contentDescription = L("langFr") .. (currentLang == "fr" and ", " .. L("languageSelected") or ""),
            textColor = TEXT_COLOR,
            textSize = responsiveSp(frText, 20, 16, 18),
            backgroundColor = GREEN_BG,
            layout_width = "match_parent",
            layout_height = "wrap_content",
            layout_marginBottom = "8dp"
          },
          {
            Button,
            id = "langEnglish",
            text = enText,
            contentDescription = L("langEn") .. (currentLang == "en" and ", " .. L("languageSelected") or ""),
            textColor = TEXT_COLOR,
            textSize = responsiveSp(enText, 20, 16, 18),
            backgroundColor = GREEN_BG,
            layout_width = "match_parent",
            layout_height = "wrap_content",
            layout_marginBottom = "8dp"
          },
          {
            Button,
            id = "btnLangCancel",
            text = L("cancel"),
            contentDescription = L("cancel"),
            textColor = TEXT_COLOR,
            textSize = responsiveSp(L("cancel"), 20, 16, 18),
            backgroundColor = BUTTON_BLUE,
            layout_width = "match_parent",
            layout_height = "wrap_content"
          }
        }
      }
      dlgLang.View = loadlayout(langLayout)
      dlgLang.show()
      speakDelayed(L("langSelectedSpoken"))
      _G.langArabic.onClick = function()
        playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
        currentLang = "ar"
        fLang:write("ar")
        dlgLang.dismiss()
        if scj then scj.dismiss() end
        farouqTi1()
        speakDelayed(L("languageChanged"))
      end
      _G.langFrench.onClick = function()
        playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
        currentLang = "fr"
        fLang:write("fr")
        dlgLang.dismiss()
        if scj then scj.dismiss() end
        farouqTi1()
        speakDelayed(L("languageChanged"))
      end
      _G.langEnglish.onClick = function()
        playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
        currentLang = "en"
        fLang:write("en")
        dlgLang.dismiss()
        if scj then scj.dismiss() end
        farouqTi1()
        speakDelayed(L("languageChanged"))
      end
      _G.btnLangCancel.onClick = function()
        playSafeTone(ToneGenerator.TONE_CDMA_LOW_PBX_L, 120)
        returnToSettings()
      end
    end
    _G.btnChangeColumns.onClick = function()
      playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
      dlgSettings.dismiss()
      local dlgCols = LuaDialog(service)
      local function returnToSettings()
        dlgCols.dismiss()
        dlgSettings.show()
      end
      dlgCols.setOnKeyListener(function(dialog, keyCode, event)
        if keyCode == KeyEvent.KEYCODE_BACK and event.getAction() == KeyEvent.ACTION_UP then
          returnToSettings()
          return true
        end
        return false
      end)
      local c1Text = (currentColumns == 1) and ("✓ " .. L("col1")) or L("col1")
      local c2Text = (currentColumns == 2) and ("✓ " .. L("col2")) or L("col2")
      local c3Text = (currentColumns == 3) and ("✓ " .. L("col3")) or L("col3")
      local c4Text = (currentColumns == 4) and ("✓ " .. L("col4")) or L("col4")
      local colsLayout = {
        LinearLayout,
        orientation = "vertical",
        backgroundColor = BLUE_BG,
        layout_width = "match_parent",
        layout_height = "wrap_content",
        {
          TextView,
          text = L("selectColumnsTitle"),
          textColor = TEXT_COLOR,
          textSize = responsiveSp(L("selectColumnsTitle"), 35, 28, 16),
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
          padding = "10dp",
          {
            Button,
            id = "colBtn1",
            text = c1Text,
            textColor = TEXT_COLOR,
            textSize = responsiveSp(c1Text, 20, 16, 18),
            backgroundColor = GREEN_BG,
            layout_width = "match_parent",
            layout_height = "wrap_content",
            layout_marginBottom = "8dp"
          },
          {
            Button,
            id = "colBtn2",
            text = c2Text,
            textColor = TEXT_COLOR,
            textSize = responsiveSp(c2Text, 20, 16, 18),
            backgroundColor = GREEN_BG,
            layout_width = "match_parent",
            layout_height = "wrap_content",
            layout_marginBottom = "8dp"
          },
          {
            Button,
            id = "colBtn3",
            text = c3Text,
            textColor = TEXT_COLOR,
            textSize = responsiveSp(c3Text, 20, 16, 18),
            backgroundColor = GREEN_BG,
            layout_width = "match_parent",
            layout_height = "wrap_content",
            layout_marginBottom = "8dp"
          },
          {
            Button,
            id = "colBtn4",
            text = c4Text,
            textColor = TEXT_COLOR,
            textSize = responsiveSp(c4Text, 20, 16, 18),
            backgroundColor = GREEN_BG,
            layout_width = "match_parent",
            layout_height = "wrap_content",
            layout_marginBottom = "8dp"
          },
          {
            Button,
            id = "btnColsCancel",
            text = L("cancel"),
            contentDescription = L("cancel"),
            textColor = TEXT_COLOR,
            textSize = responsiveSp(L("cancel"), 20, 16, 18),
            backgroundColor = BUTTON_BLUE,
            layout_width = "match_parent",
            layout_height = "wrap_content"
          }
        }
      }
      dlgCols.View = loadlayout(colsLayout)
      _G.colBtn1.onClick = function()
        playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
        currentColumns = 1
        fColumns:write(1)
        dlgCols.dismiss()
        if scj then scj.dismiss() end
        farouqTi1()
        speakDelayed(L("col1"))
      end
      _G.colBtn2.onClick = function()
        playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
        currentColumns = 2
        fColumns:write(2)
        dlgCols.dismiss()
        if scj then scj.dismiss() end
        farouqTi1()
        speakDelayed(L("col2"))
      end
      _G.colBtn3.onClick = function()
        playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
        currentColumns = 3
        fColumns:write(3)
        dlgCols.dismiss()
        if scj then scj.dismiss() end
        farouqTi1()
        speakDelayed(L("col3"))
      end
      _G.colBtn4.onClick = function()
        playSafeTone(ToneGenerator.TONE_PROP_ACK, 120)
        currentColumns = 4
        fColumns:write(4)
        dlgCols.dismiss()
        if scj then scj.dismiss() end
        farouqTi1()
        speakDelayed(L("col4"))
      end
      _G.btnColsCancel.onClick = function()
        playSafeTone(ToneGenerator.TONE_CDMA_LOW_PBX_L, 120)
        returnToSettings()
      end
      dlgCols.show()
    end
    dlgSettings.show()
  end
  btnToggleMode.onClick = function()
    playSafeTone(ToneGenerator.TONE_PROP_BEEP, 120)

    -- بدّل الحالة والنص فورًا قبل أي تحديث للقائمة حتى لا يبدو الزر بطيئًا.
    if searchStage == 3 then
      searchStage = 1
      searchMode = "titles"
      currentList = t1
      btnToggleMode.setText(L("searchToggleTitle2"))
      btnToggleMode.setContentDescription(L("searchToggleTitle2"))
      searchEdit.setHint(L("searchHintTitles"))
    elseif searchStage == 1 then
      searchStage = 2
      searchMode = "content"
      currentList = t2
      btnToggleMode.setText(L("searchToggleTitle1"))
      btnToggleMode.setContentDescription(L("searchToggleTitle1"))
      searchEdit.setHint(L("searchHintContent"))
    else
      searchStage = 1
      searchMode = "titles"
      currentList = t1
      btnToggleMode.setText(L("searchToggleTitle2"))
      btnToggleMode.setContentDescription(L("searchToggleTitle2"))
      searchEdit.setHint(L("searchHintTitles"))
    end

    -- نظّف مربع البحث وأعد عرض المصدر الجديد مباشرة.
    searchEdit.setVisibility(View.VISIBLE)
    searchEdit.setText("")
    btnNoResult.setVisibility(View.GONE)
    refreshListAdapterPreservePosition(_G.list, getStyledAdapter(currentList))
    updateMainDialogPosition(scj, currentList)
    updateDialogHeightDynamic(scj, #currentList, 0.95, 1)