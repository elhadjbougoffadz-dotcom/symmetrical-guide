require 'import'
import "android.widget.*"
import "android.view.*"
import "com.androlua.*"
import "android.text.TextWatcher"
import "android.view.View"
import "android.widget.EditText"
import "android.widget.LinearLayout"
import "android.widget.GridView"
import "android.widget.ListView"
import "android.widget.TextView"
import "android.widget.ScrollView"
import "com.androlua.LuaDialog"
import "android.os.*"
import "android.content.*"
import "android.net.Uri"
import "android.graphics.Typeface"
import "android.media.AudioManager"
import "android.media.ToneGenerator"
import "java.io.File"
local BANNER_RED = 0xFF151515
local DELETE_RED = 0xFF1A1A1A
local BUTTON_BLUE = 0xFF1C1C1C
local BLUE_BG = 0xFF000000
local ORANGE_BG = 0xFF202020
local GREY_BG = 0xFF64B5F6
local DARK_BLUE_TITLE = 0xFF0A0A0A
local GREEN_BG = 0xFF161616
local SOFT_GREEN = 0xFF181818
local BROWN_BTN = 0xFF1A1A1A
local SELECTION_BLUE = 0xFF64B5F6
local TEXT_COLOR = 0xFFFFFFFF
local WHITE_LINE = 0xFFFFFFFF

-- يحفظ موضع أي قائمة ويعيده بعد تحديثها بدون قفز.
local function captureListPosition(listView)
  if not listView then return nil end
  local pos = { first = 0, top = 0 }
  pcall(function()
    pos.first = listView.getFirstVisiblePosition() or 0
    local child = listView.getChildAt(0)
    if child then
      pos.top = child.getTop() or 0
    end
  end)
  return pos
end

function restoreListPosition(listView, pos, delayMs)
  if not listView or not pos then return end
  local delay = delayMs or 30
  local function applyPosition()
    pcall(function()
      listView.setSelectionFromTop(pos.first or 0, pos.top or 0)
    end)
  end
  applyPosition()
  task(delay, applyPosition)
  task(delay + 100, applyPosition)
  task(delay + 250, applyPosition)
  task(delay + 450, applyPosition)
end

function refreshListAdapterPreservePosition(listView, newAdapter)
  if not listView then return end
  local pos = captureListPosition(listView)
  listView.adapter = newAdapter
  restoreListPosition(listView, pos)
end
local function applyMainDialogConstraints(dlg, hasItems)
  dlg.show()
  pcall(function()
    local window = dlg.getWindow()
    if not window then return end
    local dm = service.getResources().getDisplayMetrics()
    local screenWidth = dm.widthPixels
    window.setGravity(Gravity.CENTER)
    window.setLayout(math.floor(screenWidth * 0.95), WindowManager.LayoutParams.WRAP_CONTENT)
  end)
end
local function hasMemoItems(items)
  if type(items) ~= "table" then
    return false
  end
  for _, item in pairs(items) do
    if item ~= nil and tostring(item) ~= "" then
      return true
    end
  end
  return false
end
local function updateMainDialogPosition(dlg, items)
  pcall(function()
    local window = dlg.getWindow()
    if not window then return end
    local dm = service.getResources().getDisplayMetrics()
    window.setGravity(Gravity.CENTER)
    window.setLayout(math.floor(dm.widthPixels * 0.95), WindowManager.LayoutParams.WRAP_CONTENT)
  end)
end
local toneGenerator = nil
pcall(function()
  toneGenerator = ToneGenerator(AudioManager.STREAM_ACCESSIBILITY, 100)
end)
local function playSafeTone(toneType, duration)
  if toneGenerator and toneType then
    pcall(function()
      toneGenerator.startTone(toneType, duration or 150)
    end)
  end
end
local function playFavTone()
  playSafeTone(ToneGenerator.TONE_CDMA_HIGH_L, 220)
end
local function playClipTone()
  playSafeTone(ToneGenerator.TONE_CDMA_CALLDROP_LITE, 150)
end
local function speakDelayed(text, delayMs)
  task(delayMs or 600, function()
    service.speak(text)
  end)
end
local function showExportNotice(message)
  speakDelayed(message, 300)
  pcall(function()
    Toast.makeText(service, message, Toast.LENGTH_SHORT).show()
  end)
end
playSafeTone(ToneGenerator.TONE_CDMA_CALLDROP_LITE, 200)
local path = package.searchpath("main", package.path):match("(.*)main.lua")
local json = {
  open = function(p)
    return {
      read = function()
        local s = io.readall(p)
        s = s and (loadstring(s) or loadstring("return " .. s))
        return s and s()
      end,
      write = function(self, t)
        t = t or self
        if type(t) == "table" then
          local s = {"{"}
          for k, v in ipairs(t) do
            table.insert(s, string.format("%q,", v))
          end
          table.insert(s, "}")
          return io.saveall(p, table.concat(s, "\n"))
        elseif type(t) == "string" then
          return io.saveall(p, string.format("%q", t))
        elseif type(t) == "number" then
          return io.saveall(p, tostring(t))
        end
      end
    }
  end
}
local f1 = json.open(path .. "titles.lua")
local f2 = json.open(path .. "content.lua")
local fLang = json.open(path .. "settings_lang.lua")
local fColumns = json.open(path .. "settings_columns.lua")
local backupDirPath = "/sdcard/解说/Plugins/المذكرة الذكية/النسخ الاحتياطي والاستعادة/"
local backupDir = File(backupDirPath)
pcall(function()
  if not backupDir.exists() then
    backupDir.mkdirs()
  end
end)
local backupMemoFile = backupDirPath .. "المذكرة الذكية.lua"
local backupJieshuoClipboardFile = backupDirPath .. "حافظة Jieshuo.lua"
local backupJieshuoFavoritesFile = backupDirPath .. "مفضلة Jieshuo.lua"
local backupDeviceClipboardFile = backupDirPath .. "حافظة الجهاز.lua"
local backupFilesByIndex = {
  [1] = backupMemoFile,
  [2] = backupJieshuoClipboardFile,
  [3] = backupJieshuoFavoritesFile,
  [4] = backupDeviceClipboardFile
}
local backupNamesByIndex = {
  [1] = "المذكرة الذكية",
  [2] = "حافظة Jieshuo",
  [3] = "مفضلة Jieshuo",
  [4] = "حافظة الجهاز"
}
local backupIndexByKind = {
  jieshuoClipboard = 2,
  jieshuoFavorites = 3,
  deviceClipboard = 4
}
local function ensureBackupDirectory()
  local ok = false
  pcall(function()
    if not backupDir.exists() then backupDir.mkdirs() end
    ok = backupDir.exists() and backupDir.isDirectory()
  end)
  return ok
end
local function serializeBackupValue(value, seen)
  seen = seen or {}
  local valueType = type(value)
  if valueType == "string" then
    return string.format("%q", value)
  elseif valueType == "number" or valueType == "boolean" then
    return tostring(value)
  elseif valueType == "nil" then
    return "nil"
  elseif valueType == "table" then
    if seen[value] then return "nil" end
    seen[value] = true
    local parts = {"{"}
    for k, item in pairs(value) do
      local keyText
      if type(k) == "number" then
        keyText = "[" .. tostring(k) .. "]"
      elseif type(k) == "string" then
        keyText = "[" .. string.format("%q", k) .. "]"
      end
      if keyText then
        parts[#parts + 1] = keyText .. "=" .. serializeBackupValue(item, seen) .. ","
      end
    end
    parts[#parts + 1] = "}"
    seen[value] = nil
    return table.concat(parts, "\n")
  end
  return "nil"
end
local function writeBackupFile(filePath, kind, data)
  if not ensureBackupDirectory() then return false end
  local payload = "return {version=\"SMART_NOTE_BACKUP_V5\",kind=" ..
    string.format("%q", kind) .. ",data=" .. serializeBackupValue(data or {}) .. "}"
  local written = false
  pcall(function()
    local out = io.open(filePath, "w")
    if out then
      out:write(payload)
      out:flush()
      out:close()
      written = true
    end
  end)
  if not written then
    pcall(function() written = io.saveall(filePath, payload) and true or false end)
  end
  local valid = false
  pcall(function()
    local f = File(filePath)
    valid = f.exists() and f.isFile() and f.length() > 10
  end)
  return written and valid
end
local function readBackupFile(filePath, expectedKind)
  local exists = false
  pcall(function()
    local f = File(filePath)
    exists = f.exists() and f.isFile() and f.length() > 10
  end)
  if not exists then return false, nil end
  local source = nil
  pcall(function() source = io.readall(filePath) end)
  if not source or source == "" then
    pcall(function()
      local f = io.open(filePath, "r")
      if f then source = f:read("*a"); f:close() end
    end)
  end
  if not source or source == "" then return false, nil end
  local chunk = loadstring(source)
  if not chunk then return false, nil end
  local ok, result = pcall(chunk)
  if not ok or type(result) ~= "table" then return false, nil end
  if result.version ~= "SMART_NOTE_BACKUP_V5" or result.kind ~= expectedKind or type(result.data) ~= "table" then
    return false, nil
  end
  return true, result.data
end
local deviceClipboardPath = "/sdcard/المذكرة الذكية_حافظة الجهاز.lua"
local fDeviceClipboard = json.open(deviceClipboardPath)
local function readDeviceStore(storeFile)
  local ok, data = pcall(function()
    return storeFile:read()
  end)
  if ok and type(data) == "table" then
    return data
  end
  return {}
end
local function writeDeviceStore(storeFile, data)
  pcall(function()
    storeFile:write(data or {})
  end)
end
local function getDeviceClipboardList()
  return readDeviceStore(fDeviceClipboard)
end
local function getDeviceCounts()
  local deviceClipCount = 0
  pcall(function()
    local list = getDeviceClipboardList()
    deviceClipCount = type(list) == "table" and #list or 0
  end)
  return deviceClipCount
end
local t1 = f1:read() or {}
local t2 = f2:read() or {}
local currentLang = fLang:read() or "ar"
local currentColumns = tonumber(fColumns:read()) or 2
local function cleanAndFormatTitle(text)
  local str = tostring(text or "")
  str = str:gsub("[\r\n]+", " ")
  local cleanStr = str:match("([%w%a\192-\255\1575-\1610].*)") or str
  if utf8 and utf8.len(cleanStr) and utf8.len(cleanStr) > 40 then
    local utf8Sub = ""
    local count = 0
    for _, codepoint in utf8.codes(cleanStr) do
      count = count + 1
      if count > 40 then break end
      utf8Sub = utf8Sub .. utf8.char(codepoint)
    end
    cleanStr = utf8Sub
  elseif #cleanStr > 40 then
    cleanStr = cleanStr:sub(1, 40)
  end
  if cleanStr == "" then
    cleanStr = str:sub(1, 40)
  end
  return cleanStr
end
local langDict = {
  ar = {
    appName = "المذكرة الذكية",

    memoHeader = "📖 المذكرة الذكية 📖",
    memoEmpty = "📘 المذكرة فارغة 📘",
    manageEmpty = "📘 الإدارة فارغة 📘",
    statMemo = "عدد عناصر المذكرة الذكية: ",
    statClip = "عدد عناصر حافظة Jieshuo: ",
    statFav = "عدد عناصر مفضلة Jieshuo: ",
    statDevice = "عدد عناصر حافظة الجهاز: ",
    importChoice = "الاستيراد من الحافظة أو المفضلة",
    exportChoice = "التصدير إلى الحافظة أو المفضلة",
    importAll = "إستيراد الكل",
    importSelected = "إستيراد المحدد",
    backup = "نسخ احتياطي",
    backupCreated = "تم إنشاء %s نسخ احتياطية وحفظها فعلياً في المسار المحدد",
    backupPartial = "تم حفظ %s من النسخ الاحتياطية، وتعذر حفظ %s",
    backupFailed = "تعذر حفظ النسخ الاحتياطية. تحقق من مسار التخزين وصلاحيات الكتابة",
    restoreDone = "تمت استعادة %s نسخ احتياطية بنجاح، وتمت استعادة الحافظة والمفضلة دفعة واحدة لكل قسم",
    restorePartial = "تمت استعادة %s عناصر، مع وجود %s نسخة غير موجودة و%s نسخة غير صالحة",
    restoreFailed = "لا توجد نسخة احتياطية محفوظة في المسار المحدد أو أن الملفات غير صالحة",
    noSelection = "لم يتم تحديد أي عنصر",
    invertSelectionSpoken = "العناصر المحددة: %s، العناصر غير المحددة: %s",
    backupSuccess = "تم النسخ الاحتياطي: %s عنصر",
    backupCreateFailed = "تعذر إنشاء النسخة الاحتياطية",
    deleteSelected = "تم حذف %s عناصر",
    deleteSelectedFailed = "تعذر حذف العناصر",
    selectToDelete = "حدد العناصر المراد حذفها",
    exportFavSuccess2 = "تم التصدير إلى مفضلة Jieshuo بنجاح",
    exportFavFailed = "فشل التصدير إلى مفضلة Jieshuo",
    exportClipSuccess2 = "تم التصدير إلى حافظة Jieshuo بنجاح",
    exportClipFailed = "فشل التصدير إلى حافظة Jieshuo",
    exportDeviceSuccess2 = "تم التصدير إلى حافظة الجهاز بنجاح",
    exportDeviceFailed = "فشل التصدير إلى حافظة الجهاز",
    selectedSpokenShort = "محدد",
    selectedPrefix = "محدد: ",
    searchToggleTitle1 = "التبديل للبحث في العنوان",
    searchToggleTitle2 = "التبديل للبحث في المحتوى",
    searchToggleTitle3 = "البحث في العنوان أو المحتوى",
    searchHintTitles = "بحث في العناوين...",
    searchHintContent = "بحث في المحتوى...",
    noResult = "لم يتم العثور على أي نتيجة",
    importBtn = "إستيراد",
    manageBtn = "إِدَارَة",
    homeBtn = "الرئيسية",
    addBtn = "إِضَافة",
    exitBtn = "خروج",
    settingsBtn = "الإعدادات",
    clipboard = "حافظة Jieshuo",
    favorites = "مفضلة Jieshuo",
    done = "تم",
    cancel = "إلغاء",
    next = "التالي",
    editTitle = "تعديل العنوان",
    editContent = "تعديل المحتوى",
    settingsTitle = "الإعدادات",
    manageItems = "إدارة العناصر",
    importExport = "الاستيراد والتصدير",
    changeColumns = "تغيير عدد الأعمدة",
    changeLang = "تغيير اللغة",
    memoStats = "إحصائيات المذكرة",
    moreInfo = "مزيد من المعلومات",
    backupRestore = "النسخ الاحتياطي والاستعادة",
    createBackup = "إنشاء نسخة احتياطية",
    restoreBackup = "استعادة النسخة الاحتياطية",
    backupMemo = "المذكرة الذكية",
    backupJieshuoClipboard = "حافظة Jieshuo",
    backupJieshuoFavorites = "مفضلة Jieshuo",
    backupDeviceClipboard = "حافظة الجهاز",
    backupSelectTitle = "اختر ما تريد نسخه احتياطيًا؟",
    restoreSelectTitle = "اختر ما تريد استعادته من النسخة الاحتياطية؟",
    restoreConfirmMessage = "سيتم تهيئة المذكرة على النسخة الجديدة واستبدال البيانات المحددة بالبيانات الموجودة في النسخة الاحتياطية. هل تريد المتابعة؟",
    backupConfirmMessage = "سيتم مسح النسخ الاحتياطية المحددة المخزنة واستبدالها بهذه النسخ الجديدة. هل تريد المتابعة؟",
    selected = "محدد",
    unselected = "غير محدد",
    allSelected = "تم تحديد الكل",
    allDeselected = "تم إلغاء تحديد الكل",
    printSplitLines = "التقسيم بالأسطر",
    printWholeText = "النص كله",
    enhancedDescription = "النسخة المحسنة والمطورة مع دعم متعدد اللغات.",
    languageSelected = "محدد",
    langSelectedSpoken = "اللغة العربية، محدد",
    languageChanged = "تم اختيار اللغة العربية",
    selectLangTitle = "اختر اللغة",
    langAr = "العربية (ARABIC)",
    langFr = "الفرنسية (FRENCH)",
    langEn = "الإنجليزية (ENGLISH)",
    selectColumnsTitle = "اختر نمط العرض",
    col1 = "عمودي عادي (عنصر واحد)",
    col2 = "شبكة من عمودين",
    col3 = "شبكة من 3 أعمدة",
    col4 = "شبكة من 4 أعمدة",
    manageTitle = "إدارة العناصر",
    selectAll = "تحديد الكل",
    cancelSelectAll = "إلغاء تحديد الكل",
    invertSelection = "عكس التحديد",
    share = "مشاركة",
    exportClip = "حافظة Jieshuo",
    exportFav = "مفضلة Jieshuo",
    importDeviceClip = "حافظة الجهاز",
    exportDeviceClip = "حافظة الجهاز",
    emptyDeviceClipMsg = "حافظة الجهاز فارغة",
    deviceClipboardTitle = "حافظة الجهاز",
    exportDeviceClipSuccess = "تم التصدير إلى حافظة الجهاز بنجاح",
    delete = "حذف",
    addContentTitle = "إضافة المحتوى",
    contentHint = "اكتب المحتوى هنا...",
    addTitleTitle = "إضافة العنوان",
    titleHint = "اكتب العنوان هنا...",
    itemOptions = "خيارات العنصر",
    actionTitle = "الإجراء المراد استخدامه",
    paste = "لصق",
    copy = "نسخ",
    print = "طباعة",
    clear = "مسح",
    noteCountMsg = "عناصر المذكرة الذكية ",
    clipCountMsg = "، عناصر حافظة Jieshuo ",
    favCountMsg = "، عناصر مفضلة Jieshuo ",
    titleLimitMsg = "لا يتجاوز طول العنوان 40 حرفاً",
    emptyTitleMsg = "الرجاء كتابة العنوان أولاً",
    emptyContentMsg = "لا يتم هذا الاجراء الا بكتابة المحتوى",
    emptyClipMsg = "الحافظة فارغة",
    emptyFavMsg = "المفضلة فارغة",
    editTitleSuccess = "تم تعديل العنوان بنجاح",
    editContentSuccess = "تم تعديل المحتوى بنجاح",
    addSuccess = "تمت إضافة العنصر بنجاح",
    deleteSuccess = "تم مسح العناصر بنجاح",
    exportClipSuccess = "تم التصدير إلى الحافظة بنجاح",
    exportFavSuccess = "تم التصدير إلى المفضلة بنجاح",
    singleDeleteSuccess = "تم مسح العنصر بنجاح",
    allDeleteSuccess = "تم مسح جميع العناصر بنجاح",
    copied = "تم النسخ",
    calling = "جاري الاتصال",
    notANumber = "ليس رقماً للإتصال به",
    openLink = "جاري فتح الرابط",
    noLink = "لا يوجد رابط لفتحه",
    movedFirst = "تم النقل لأول القائمة",
    movedTop = "تم النقل للأعلى",
    alreadyTop = "العنصر موجود بالفعل في أعلى القائمة",
    manualMoveHint = "أُنْقُلِ التركيزَ إلى المكانِ المناسِبْ, ثمَّ أُنْقُرْ مرتين",
    movedLast = "تم النقل لآخر القائمة",
    movedBottom = "تم النقل للأسفل",
    alreadyBottom = "العنصر موجود بالفعل في أسفل القائمة",
    selectItemsToDelete = "لم يتم تحديد أي شيء",
    deletePrompt1 = "هل تريد حذف هذا العنصر؟",
    deletePrompt2 = "هل تريد حذف عنصرين؟",
    deletePromptMany = "هل تريد حذف ",
    deletePromptManySuffix = " عناصر؟",
    sharePrompt = "مشاركة المذكرة عبر",
    selectAllSpoken = "تم تحديد الكل، العناصر المحددة ",
    cancelSelectAllSpoken = "تم إلغاء تحديد الكل",
    itemSelectedSpoken = "محدد",
    itemDeselectedSpoken = "غير محدد",
    rangeStartSpoken = "تم بدء التحديد من العنصر الحالي بالضغط المطول وتحديد ما بينهما.",
    rangeSelectedMsg = "تم تحديد العناصر المحددة ما بين العنصرين، العناصر المحددة: ",
    menuOpt1 = "تعديلُ العنوانِ أَوِ المحتوى",
    menuOpt2 = "نَسْخُ العنوانِ أَوْ العنوانِ والمحتوى معاً",
    menuOpt3 = "الإتصال أو فتحُ الرابط",
    menuOpt4 = "نَقْلٌ لِأَوَّلِ القائمةِ أو آخِرِها",
    menuOpt5 = "نَقْلٌ لِلأَعْلَى أَوْ لِلأَسْفَلِ",
    menuOpt6 = "نَقْلٌ يَدَوي",
    menuOpt7 = "حَذْفْ أو حَذْفُ الكُل",
    menuOpt8 = "إدارة العناصر"
  },
  fr = {
    appName = "Bloc-Notes Intelligent",

    memoHeader = "📖 BLOC-NOTES 📖",
    memoEmpty = "📘 NOTE VIDE 📘",
    manageEmpty = "📘 GESTION VIDE 📘",
    statMemo = "Nombre d’éléments de la note : ",
    statClip = "Nombre d’éléments du presse-papiers Jieshuo : ",
    statFav = "Nombre d’éléments des favoris Jieshuo : ",
    statDevice = "Nombre d’éléments du presse-papiers de l’appareil : ",
    importChoice = "Importer depuis le presse-papiers ou les favoris",
    exportChoice = "Exporter vers le presse-papiers ou les favoris",
    importAll = "Tout importer",
    importSelected = "Importer la sélection",
    backup = "Sauvegarde",
    backupCreated = "%s sauvegardes ont été créées et enregistrées dans le chemin indiqué",
    backupPartial = "%s sauvegardes ont été enregistrées, %s n’ont pas pu l’être",
    backupFailed = "Impossible d’enregistrer les sauvegardes. Vérifiez le chemin de stockage et les autorisations d’écriture",
    restoreDone = "%s sauvegardes ont été restaurées avec succès, avec restauration du presse-papiers et des favoris pour chaque section",
    restorePartial = "%s éléments restaurés, %s sauvegardes introuvables et %s sauvegardes invalides",
    restoreFailed = "Aucune sauvegarde valide trouvée dans le chemin indiqué",
    noSelection = "Aucun élément sélectionné",
    invertSelectionSpoken = "Éléments sélectionnés : %s, éléments non sélectionnés : %s",
    backupSuccess = "Sauvegarde créée : %s élément(s)",
    backupCreateFailed = "Impossible de créer la sauvegarde",
    deleteSelected = "%s éléments supprimés",
    deleteSelectedFailed = "Impossible de supprimer les éléments",
    selectToDelete = "Sélectionnez les éléments à supprimer",
    exportFavSuccess2 = "Exporté vers les favoris Jieshuo avec succès",
    exportFavFailed = "Échec de l’exportation vers les favoris Jieshuo",
    exportClipSuccess2 = "Exporté vers le presse-papiers Jieshuo avec succès",
    exportClipFailed = "Échec de l’exportation vers le presse-papiers Jieshuo",
    exportDeviceSuccess2 = "Exporté vers le presse-papiers de l’appareil avec succès",
    exportDeviceFailed = "Échec de l’exportation vers le presse-papiers de l’appareil",
    selectedSpokenShort = "Sélectionné",
    selectedPrefix = "Sélectionné : ",
    searchToggleTitle1 = "Basculer vers la recherche par titre",
    searchToggleTitle2 = "Basculer vers la recherche par contenu",
    searchToggleTitle3 = "Rechercher dans le titre ou le contenu",
    searchHintTitles = "Rechercher dans les titres...",
    searchHintContent = "Rechercher dans le contenu...",
    noResult = "Aucun résultat trouvé",
    importBtn = "Importer",
    manageBtn = "Gérer",
    homeBtn = "Accueil",
    addBtn = "Ajouter",
    exitBtn = "Quitter",
    settingsBtn = "Paramètres",
    clipboard = "Presse-papiers Jieshuo",
    favorites = "Favoris Jieshuo",
    done = "Terminé",
    cancel = "Annuler",
    next = "Suivant",
    editTitle = "Modifier le titre",
    editContent = "Modifier le contenu",
    settingsTitle = "Paramètres",
    manageItems = "Gérer les éléments",
    importExport = "Importation et exportation",
    changeColumns = "Changer le nombre de colonnes",
    changeLang = "Changer la langue",
    memoStats = "Statistiques de la note",
    moreInfo = "Plus d'informations",
    backupRestore = "Sauvegarde et restauration",
    createBackup = "Créer une sauvegarde",
    restoreBackup = "Restaurer la sauvegarde",
    backupMemo = "Bloc-Notes Intelligent",
    backupJieshuoClipboard = "Presse-papiers Jieshuo",
    backupJieshuoFavorites = "Favoris Jieshuo",
    backupDeviceClipboard = "Presse-papiers de l’appareil",
    backupSelectTitle = "Que voulez-vous sauvegarder ?",
    restoreSelectTitle = "Que voulez-vous restaurer depuis la sauvegarde ?",
    restoreConfirmMessage = "La note sera initialisée avec la nouvelle sauvegarde et les données sélectionnées seront remplacées par celles de la sauvegarde. Voulez-vous continuer ?",
    backupConfirmMessage = "Les sauvegardes sélectionnées seront supprimées et remplacées par ces nouvelles sauvegardes. Voulez-vous continuer ?",
    selected = "Sélectionné",
    unselected = "Non sélectionné",
    allSelected = "Tout est sélectionné",
    allDeselected = "Toute la sélection a été annulée",
    printSplitLines = "Découper en lignes",
    printWholeText = "Texte complet",
    enhancedDescription = "Version améliorée avec prise en charge multilingue.",
    languageSelected = "Sélectionnée",
    langSelectedSpoken = "Langue française, sélectionnée",
    languageChanged = "Langue française sélectionnée",
    selectLangTitle = "Choisir la langue",
    langAr = "Arabe (ARABE)",
    langFr = "Français (FRANÇAIS)",
    langEn = "Anglais (ANGLAIS)",
    selectColumnsTitle = "Choisir le mode d'affichage",
    col1 = "Normal (1 colonne)",
    col2 = "Grille (2 colonnes)",
    col3 = "Grille (3 colonnes)",
    col4 = "Grille (4 colonnes)",
    manageTitle = "Gérer les éléments",
    selectAll = "Tout sélectionner",
    cancelSelectAll = "Tout désélectionner",
    invertSelection = "Inverser la sélection",
    share = "Partager",
    exportClip = "Presse-papiers Jieshuo",
    exportFav = "Favoris Jieshuo",
    importDeviceClip = "Importer depuis la mémoire de l’appareil",
    exportDeviceClip = "Exporter vers la mémoire de l’appareil",
    emptyDeviceClipMsg = "La mémoire de l’appareil est vide",
    deviceClipboardTitle = "Presse-papiers de l’appareil",
    exportDeviceClipSuccess = "Exporté vers la mémoire de l’appareil",
    delete = "Supprimer",
    addContentTitle = "Ajouter du contenu",
    contentHint = "Écrivez le contenu ici...",
    addTitleTitle = "Ajouter un titre",
    titleHint = "Écrivez le titre ici...",
    itemOptions = "Options de l'élément",
    actionTitle = "Action à utiliser",
    paste = "Coller",
    copy = "Copier",
    print = "Imprimer le contenu",
    clear = "Effacer",
    noteCountMsg = "Éléments de notes ",
    clipCountMsg = ", Presse-papiers Jieshuo ",
    favCountMsg = ", Favoris Jieshuo ",
    titleLimitMsg = "Le titre ne doit pas dépasser 40 caractères",
    emptyTitleMsg = "Veuillez d'abord écrire le titre",
    emptyContentMsg = "Cette action nécessite du contenu",
    emptyClipMsg = "Le presse-papiers est vide",
    emptyFavMsg = "Les favoris sont vides",
    editTitleSuccess = "Titre modifié avec succès",
    editContentSuccess = "Contenu modifié avec succès",
    addSuccess = "Élément ajouté avec succès",
    deleteSuccess = "Éléments supprimés avec succès",
    exportClipSuccess = "Exporté vers le presse-papiers",
    exportFavSuccess = "Exporté vers les favoris",
    singleDeleteSuccess = "Élément supprimé avec succès",
    allDeleteSuccess = "Tous les éléments ont été supprimés",
    copied = "Copié",
    calling = "Appel en cours",
    notANumber = "Ce n'est pas un numéro valide",
    openLink = "Ouverture du lien",
    noLink = "Aucun lien à ouvrir",
    movedFirst = "Déplacé au début",
    movedTop = "Déplacé vers le haut",
    alreadyTop = "L'élément est déjà en haut",
    manualMoveHint = "Déplacez le focus puis double-cliquez",
    movedLast = "Déplacé à la fin",
    movedBottom = "Déplacé vers le bas",
    alreadyBottom = "L'élément est déjà en bas",
    selectItemsToDelete = "Aucun élément sélectionné",
    deletePrompt1 = "Voulez-vous supprimer cet élément ?",
    deletePrompt2 = "Voulez-vous supprimer ces 2 éléments ?",
    deletePromptMany = "Voulez-vous supprimer ",
    deletePromptManySuffix = " éléments ?",
    sharePrompt = "Partager via",
    selectAllSpoken = "Tous les éléments ont été sélectionnés",
    cancelSelectAllSpoken = "La sélection de tous les éléments a été annulée",
    itemSelectedSpoken = "Sélectionné",
    itemDeselectedSpoken = "Non sélectionné",
    rangeStartSpoken = "Sélection démarrée à partir de l'élément actuel par appui long et sélection entre les deux.",
    rangeSelectedMsg = "Éléments sélectionnés entre les deux points, nombre d'éléments sélectionnés : ",
    menuOpt1 = "Modifier le titre ou le contenu",
    menuOpt2 = "Copier le titre ou les deux",
    menuOpt3 = "Appeler ou ouvrir le lien",
    menuOpt4 = "Déplacer au début ou à la fin",
    menuOpt5 = "Déplacer vers le haut ou le bas",
    menuOpt6 = "Déplacement manuel",
    menuOpt7 = "Supprimer ou tout supprimer",
    menuOpt8 = "Sélectionner les éléments"
  },
  en = {
    appName = "Smart Note",

    memoHeader = "📖 NOTEPAD 📖",
    memoEmpty = "📘 EMPTY NOTE 📘",
    manageEmpty = "📘 EMPTY MANAGEMENT 📘",
    statMemo = "Note items: ",
    statClip = "Jieshuo clipboard items: ",
    statFav = "Jieshuo favorite items: ",
    statDevice = "Device clipboard items: ",
    importChoice = "Import from Clipboard or Favorites",
    exportChoice = "Export to Clipboard or Favorites",
    importAll = "Import All",
    importSelected = "Import Selected",
    backup = "Backup",
    backupCreated = "%s backups were created and saved to the specified path",
    backupPartial = "%s backups were saved, and %s could not be saved",
    backupFailed = "Unable to save backups. Check the storage path and write permissions",
    restoreDone = "%s backups restored successfully, including clipboard and favorites for each section",
    restorePartial = "%s items restored, with %s missing backups and %s invalid backups",
    restoreFailed = "No valid backup was found in the specified path",
    noSelection = "No item selected",
    invertSelectionSpoken = "Selected items: %s, unselected items: %s",
    backupSuccess = "Backup created: %s item(s)",
    backupCreateFailed = "Unable to create the backup",
    deleteSelected = "%s items deleted",
    deleteSelectedFailed = "Unable to delete items",
    selectToDelete = "Select the items to delete",
    exportFavSuccess2 = "Exported to Jieshuo Favorites successfully",
    exportFavFailed = "Failed to export to Jieshuo Favorites",
    exportClipSuccess2 = "Exported to Jieshuo Clipboard successfully",
    exportClipFailed = "Failed to export to Jieshuo Clipboard",
    exportDeviceSuccess2 = "Exported to device clipboard successfully",
    exportDeviceFailed = "Failed to export to device clipboard",
    selectedSpokenShort = "Selected",
    selectedPrefix = "Selected: ",
    searchToggleTitle1 = "Switch to Search in Title",
    searchToggleTitle2 = "Switch to Search in Content",
    searchToggleTitle3 = "Search in Title or Content",
    searchHintTitles = "Search titles...",
    searchHintContent = "Search content...",
    noResult = "No results found",
    importBtn = "Import",
    manageBtn = "Manage",