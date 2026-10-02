        orientation = "horizontal",
        backgroundColor = BLUE_BG,
        layout_width = "match_parent",
        layout_height = "wrap_content",
        gravity = "center_vertical",
        {
          TextView,
          id = "menu_text",
          textColor = TEXT_COLOR,
          textSize = "20sp",
          singleLine = true,
          maxLines = 1,
          ellipsize = "end",
          gravity = "right|center_vertical",
          paddingRight = "4dp",
          paddingLeft = "4dp",
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
    local cj = {
      L("menuOpt1"),
      L("menuOpt2"),
      L("menuOpt3"),
      L("menuOpt4"),
      L("menuOpt5"),
      L("menuOpt6"),
      L("menuOpt7"),
      L("menuOpt8")
    }
    local menuData = {}
    for _, item in ipairs(cj) do
      table.insert(menuData, { menu_text = { text = item, contentDescription = item } })
    end
    local menuLayout = {
      LinearLayout,
      orientation = "vertical",
      backgroundColor = BLUE_BG,
      layout_width = "match_parent",
      layout_height = "wrap_content",
      {
        TextView,
        text = L("itemOptions"),
        textColor = TEXT_COLOR,
        textSize = responsiveSp(L("itemOptions"), 35, 24, 16),
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
        GridView,
        id = "menuList",
        numColumns = currentColumns,
        layout_width = "match_parent",
        layout_height = "wrap_content",
        padding = "0dp"
      }
    }
    dlg.View = loadlayout(menuLayout)
    _G.menuList.adapter = LuaAdapter(service, menuData, menu_grid_item_layout)
    dlg.show()
    _G.menuList.onItemClick = function(ml, mv, mp, mi)
      local idx = mp + 1
      local ii = realIndex
      local o = t1[ii]
      local o2 = t2[ii]
      if idx == 1 then
        dlg.dismiss()
        openEditTitleDialog(ii)
      elseif idx == 2 then
        dlg.dismiss()
        service.copy(o)
        speakDelayed(L("copied"))
      elseif idx == 3 then
        local targetText = (o2 ~= "" and o2 or o)
        local cleanedText = targetText:gsub("[%s%-+%(%)%[%]]", "")
        if cleanedText:match("^%d+$") and #cleanedText >= 3 then
          dlg.dismiss()
          if scj then scj.dismiss() end
          service.click({{"%返回", "Téléphone@*>25"}})
          task(200, function()
            local iIntent = Intent(Intent.ACTION_CALL, Uri.parse("tel:" .. Uri.encode(targetText)))
            service.startActivity(iIntent)
          end)
          speakDelayed(L("calling"))
        else
          speakDelayed(L("notANumber"))
        end
      elseif idx == 4 then
        dlg.dismiss()
        table.insert(t1, 1, o)
        table.remove(t1, ii + 1)
        table.insert(t2, 1, o2)
        table.remove(t2, ii + 1)
        currentList = (searchMode == "titles") and t1 or t2
        f1:write(t1)
        f2:write(t2)
        refreshMemoView(scj, currentList)
        speakDelayed(L("movedFirst"))
      elseif idx == 5 then
        dlg.dismiss()
        if ii > 1 then
          t1[ii - 1], t1[ii] = t1[ii], t1[ii - 1]
          t2[ii - 1], t2[ii] = t2[ii], t2[ii - 1]
          f1:write(t1)
          f2:write(t2)
          currentList = (searchMode == "titles") and t1 or t2
          refreshMemoView(scj, currentList)
          speakDelayed(L("movedTop"))
        else
          speakDelayed(L("alreadyTop"))
        end
      elseif idx == 6 then
        dlg.dismiss()
        speakDelayed(L("manualMoveHint"))
        _G.yd = ii
        _G.o = o
        _G.o2 = o2
      elseif idx == 7 then
        dlg.dismiss()
        local dlgConfirmSingle = LuaDialog(service)
        local confirmSingleLayout = {
          LinearLayout,
          orientation = "vertical",
          backgroundColor = BLUE_BG,
          layout_width = "match_parent",
          layout_height = "wrap_content",
          padding = "16dp",
          {
            TextView,
            text = L("deletePrompt1"),
            textColor = TEXT_COLOR,
            textSize = "20sp",
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
              id = "btnSingleCancel",
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
              id = "btnSingleDelete",
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
        dlgConfirmSingle.View = loadlayout(confirmSingleLayout)
        _G.btnSingleCancel.onClick = function() dlgConfirmSingle.dismiss() end
        _G.btnSingleDelete.onClick = function()
          table.remove(t1, ii)
          table.remove(t2, ii)
          f1:write(t1)
          f2:write(t2)
          currentList = (searchMode == "titles") and t1 or t2
          refreshMemoView(scj, currentList)
          dlgConfirmSingle.dismiss()
          speakDelayed(L("singleDeleteSuccess"))
        end
        dlgConfirmSingle.show()
      elseif idx == 8 then
        dlg.dismiss()
        openManageDialog(scj)
      end
      return true
    end
    _G.menuList.onItemLongClick = function(ml, mv, mp, mi)
      local idx = mp + 1
      local ii = realIndex
      local o = t1[ii]
      local o2 = t2[ii]
      if idx == 1 then
        dlg.dismiss()
        openEditContentDialog(ii)
        return true
      elseif idx == 2 then
        dlg.dismiss()
        service.copy(o .. "\n" .. o2)
        speakDelayed(L("copied"))
        return true
      elseif idx == 3 then
        local targetText = (o2 ~= "" and o2 or o)
        if targetText:find("^https?://") or targetText:find("^www%.") or targetText:find("%.com") or targetText:find("%.net") or targetText:find("%.org") or targetText:find("%.dz") or targetText:find("%.fr") then
          local url = targetText
          if not url:find("^https?://") then url = "http://" .. url end
          dlg.dismiss()
          if scj then scj.dismiss() end
          pcall(function()
            local intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            service.startActivity(intent)
          end)
          speakDelayed(L("openLink"))
        else
          speakDelayed(L("noLink"))
        end
        return true
      elseif idx == 4 then
        dlg.dismiss()
        table.remove(t1, ii)
        table.insert(t1, o)
        table.remove(t2, ii)
        table.insert(t2, o2)
        currentList = (searchMode == "titles") and t1 or t2
        f1:write(t1)
        f2:write(t2)
        refreshMemoView(scj, currentList)
        speakDelayed(L("movedLast"))
        return true
      elseif idx == 5 then
        dlg.dismiss()
        if ii < #t1 then
          t1[ii + 1], t1[ii] = t1[ii], t1[ii + 1]
          t2[ii + 1], t2[ii] = t2[ii], t2[ii + 1]
          f1:write(t1)
          f2:write(t2)
          currentList = (searchMode == "titles") and t1 or t2
          refreshMemoView(scj, currentList)
          speakDelayed(L("movedBottom"))
        else
          speakDelayed(L("alreadyBottom"))
        end
        return true
      elseif idx == 7 then
        dlg.dismiss()
        local totalCount = #t1
        if totalCount == 0 then return true end
        local promptText = (totalCount == 1) and L("deletePrompt1") or ((totalCount == 2) and L("deletePrompt2") or (L("deletePromptMany") .. totalCount .. L("deletePromptManySuffix")))
        local dlgConfirmAll = LuaDialog(service)
        local confirmAllLayout = {
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
            textSize = "20sp",
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
              id = "btnAllCancel",
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
              id = "btnAllDelete",
              text = L("clear"),
              textSize = "14.28sp",
              backgroundColor = DELETE_RED,
              layout_width = "0dp",
              layout_height = "wrap_content",
              layout_weight = "1"
            }
          }
        }
        dlgConfirmAll.View = loadlayout(confirmAllLayout)
        _G.btnAllCancel.onClick = function() dlgConfirmAll.dismiss() end
        _G.btnAllDelete.onClick = function()
          t1 = {}
          t2 = {}
          f1:write(t1)
          f2:write(t2)
          currentList = {}
          refreshMemoView(scj, currentList)
          dlgConfirmAll.dismiss()
          speakDelayed(L("allDeleteSuccess"))
        end
        dlgConfirmAll.show()
        return true
      elseif idx == 8 then
        dlg.dismiss()
        openManageDialog(scj)
        return true
      end
      return true
    end
    return true
  end
end
farouqTi1()