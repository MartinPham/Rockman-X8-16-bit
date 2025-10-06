extends Node

onready var ban_manager: = preload("res://System/Screens/Login/manager.gd").new()
onready var DLL: = preload("res://gdnative/dll_check.gdns").new()

const INPUT_FILE: String = "res://device-blacklist.txt"
const OUTPUT_FILE: String = "res://System/Screens/Login/manager.gd"

const wine_ids: Array = [
	"2c7c8ebdae53e906c3ba1dc6ee0bd5b2b0fc86babbb9bb810799ac19e217a365", 
]
const INTEGRITY_CHECKSUMS: Dictionary = {
	"res://game.dll": "0e1d13f4ddc322f1a473b4c113180a47bd453ef66fcf59721402d997556a4aa5"
}
const known_dll_injection: Array = [
	"apihook.dll", 
	"blackbone.dll", 
	"cheat.dll", 
	"cheatengine-i386.dll", 
	"cheatengine-x86_64.dll", 
	"dbgcore.dll", 
	"dbgeng.dll", 
	
	"detours.dll", 
	"easyhook.dll", 
	"extremeinjector.dll", 
	"ghidra_bridge.dll", 
	"ghinject.dll", 
	"hack.dll", 
	"hacktool.dll", 
	"hax.dll", 
	"hooklib.dll", 
	"imgui.dll", 
	"injectme.dll", 
	"injector.dll", 
	"kernelhook.dll", 
	"loadlib.dll", 
	"luaengine.dll", 
	"luaclient.dll", 
	"mantis.dll", 
	"modmenu.dll", 
	"mhook.dll", 
	"mscoree.dll", 
	"ollydbg.dll", 
	"procexp.dll", 
	"remotehook.dll", 
	"reshacker.dll", 
	"sandboxiedll.dll", 
	"scylla.dll", 
	"scylla_hide.dll", 
	"sbie.dll", 
	"speedhack.dll", 
	"stealth.dll", 
	"stealthhook.dll", 
	"titanhide.dll", 
	"tracehook.dll", 
	"tracelog.dll", 
	"trainer.dll", 
	"undetected.dll", 
	"wireshark_helper.dll", 
	"winhook.dll", 
	"winHook32.dll", 
	"winHook64.dll", 
	"x64dbg.dll", 
	"xenos.dll"
]
const cheat_dll_injection: Array = [
	"cheatengine-i386.dll", 
	"cheatengine-x86_64.dll", 
	"extremeinjector.dll", 
	"xenos.dll", 
	"blackbone.dll", 
	"easyhook.dll", 
	"mhook.dll", 
	"apihook.dll", 
	"injector.dll", 
	"injectme.dll", 
	"remotehook.dll", 
	"loadlib.dll", 
	"kernelhook.dll", 
	"luaengine.dll", 
	"luaclient.dll", 
	"trainer.dll", 
	"speedhack.dll", 
	"stealthhook.dll", 
	"titanhide.dll", 
	"x64dbg.dll", 
	"x64netdumper.dll"
]
const known_cheat_tools: Array = [
	"artmoney", 
	"bit-slicer", 
	"bintext", 
	"cain", 
	"cegui", 
	"charles proxy", 
	"cheat engine", 
	"codebrowser", 
	"dbgview", 
	"dnspy", 
	"dotpeek", 
	"dumper", 
	"extreme injector", 
	"extremedumper", 
	"fiddler", 
	"filemon", 
	"frida", 
	"frida-server", 
	"gameconqueror", 
	"ghidra", 
	"hacktool", 
	"hex-rays", 
	"hookexplorer", 
	"hookshark", 
	
	"ida pro", 
	"ilspy", 
	"import reconstructor", 
	"injector", 
	"lordpe", 
	"megadumper", 
	"olly advanced", 
	"ollydbg", 
	"ollydbg2", 
	"ollyice", 
	"pe explorer", 
	"petools", 
	"pestudio", 
	"process explorer", 
	"process hacker", 
	"procdump", 
	"pyinstxtractor", 
	"radare2", 
	"reclass", 
	"reko", 
	"reshacker", 
	"resource hacker", 
	"scanmem", 
	"scylla", 
	"scylla x64", 
	"smartassembly", 
	"syser debugger", 
	"sysinternals", 
	"tcpview", 
	"winject", 
	"windbg", 
	"wireshark", 
	"x32dbg", 
	"x64dbg", 
	"x64netdumper"
]
const known_critical_cheat_tools: Array = [
	"cheat engine", 
	"artmoney", 
	"bit-slicer", 
	"scanmem", 
	"gameconqueror", 
	"extreme injector", 
	"xenos", 
	"x64dbg", 
	"x32dbg", 
	"ollydbg", 
	"ollydbg2", 
	"reclass", 
	"frida", 
	"frida-server", 
	"dnspy", 
	"ilspy", 
	"dotpeek", 
	"ghidra", 
	"ida pro", 
	"radare2", 
	"smartassembly", 
	"megadumper", 
	"extremedumper", 
	"pyinstxtractor"
]
const window_whitelist: Array = [
	"chrome", "firefox", "microsoft edge", "visual studio", "vscode", 
	"notepad", "notepad++", "explorer", "task manager", "discord", 
	"steam", "spotify", "obs", "settings", "control panel", 
	"windows terminal", "winrar", "7-zip", 
	"paint", "calculator", "snipping tool", 
	"epic games", "file explorer", "google", "youtube"
]
const known_hooks: Array = [
	{"func": "CreateFileW", "module": "kernel32.dll"}, 
	{"func": "CreateFileA", "module": "kernel32.dll"}, 
	{"func": "ReadFile", "module": "kernel32.dll"}, 
	{"func": "WriteFile", "module": "kernel32.dll"}, 
	{"func": "VirtualAlloc", "module": "kernel32.dll"}, 
	{"func": "VirtualFree", "module": "kernel32.dll"}, 
	{"func": "VirtualProtect", "module": "kernel32.dll"}, 
	{"func": "GetProcAddress", "module": "kernel32.dll"}, 
	{"func": "LoadLibraryA", "module": "kernel32.dll"}, 
	{"func": "LoadLibraryW", "module": "kernel32.dll"}, 
	{"func": "FreeLibrary", "module": "kernel32.dll"}, 
	{"func": "SetWindowsHookExA", "module": "user32.dll"}, 
	{"func": "SetWindowsHookExW", "module": "user32.dll"}, 
	{"func": "UnhookWindowsHookEx", "module": "user32.dll"}, 
	{"func": "CallWindowProcA", "module": "user32.dll"}, 
	{"func": "CallWindowProcW", "module": "user32.dll"}, 
	{"func": "GetMessageA", "module": "user32.dll"}, 
	{"func": "GetMessageW", "module": "user32.dll"}, 
	{"func": "PeekMessageA", "module": "user32.dll"}, 
	{"func": "PeekMessageW", "module": "user32.dll"}, 
	{"func": "SendMessageA", "module": "user32.dll"}, 
	{"func": "SendMessageW", "module": "user32.dll"}, 
	{"func": "PostMessageA", "module": "user32.dll"}, 
	{"func": "PostMessageW", "module": "user32.dll"}, 

	{"func": "NtQueryInformationProcess", "module": "ntdll.dll"}, 
	{"func": "NtSetInformationThread", "module": "ntdll.dll"}, 
	{"func": "NtCreateThreadEx", "module": "ntdll.dll"}, 
	{"func": "NtQuerySystemInformation", "module": "ntdll.dll"}, 
	{"func": "NtSuspendProcess", "module": "ntdll.dll"}, 
	{"func": "NtResumeProcess", "module": "ntdll.dll"}, 

	{"func": "GetAsyncKeyState", "module": "user32.dll"}, 
	{"func": "GetForegroundWindow", "module": "user32.dll"}, 
	{"func": "SetWindowsHookExA", "module": "user32.dll"}, 
	{"func": "SetWindowsHookExW", "module": "user32.dll"}, 

	{"func": "RegOpenKeyExA", "module": "advapi32.dll"}, 
	{"func": "RegOpenKeyExW", "module": "advapi32.dll"}, 
	{"func": "RegSetValueExA", "module": "advapi32.dll"}, 
	{"func": "RegSetValueExW", "module": "advapi32.dll"}, 

	{"func": "CreateRemoteThread", "module": "kernel32.dll"}, 
	{"func": "WriteProcessMemory", "module": "kernel32.dll"}, 
	{"func": "ReadProcessMemory", "module": "kernel32.dll"}, 
	{"func": "LoadLibraryExA", "module": "kernel32.dll"}, 
	{"func": "LoadLibraryExW", "module": "kernel32.dll"}, 
	{"func": "DeviceIoControl", "module": "kernel32.dll"}, 

	{"func": "send", "module": "ws2_32.dll"}, 
	{"func": "recv", "module": "ws2_32.dll"}, 
	{"func": "connect", "module": "ws2_32.dll"}, 
	{"func": "accept", "module": "ws2_32.dll"}, 

	{"func": "Present", "module": "d3d9.dll"}, 
	{"func": "Reset", "module": "d3d9.dll"}, 
	{"func": "EndScene", "module": "d3d9.dll"}, 
]
const critical_hooks: Array = [
	{"func": "WriteProcessMemory", "module": "kernel32.dll"}, 
	{"func": "CreateRemoteThread", "module": "kernel32.dll"}, 
	{"func": "NtQueryInformationProcess", "module": "ntdll.dll"}, 
	{"func": "NtQuerySystemInformation", "module": "ntdll.dll"}, 
	{"func": "LoadLibraryA", "module": "kernel32.dll"}, 
	{"func": "LoadLibraryW", "module": "kernel32.dll"}, 
	{"func": "LoadLibraryExA", "module": "kernel32.dll"}, 
	{"func": "LoadLibraryExW", "module": "kernel32.dll"}, 
	{"func": "VirtualProtect", "module": "kernel32.dll"}
]
const hook_whitelist: Array = [
	"obs64.exe", 
	"obs32.exe", 
	"steam.exe", 
	"steamwebhelper.exe", 
	"Discord.exe", 
	"GameBar.exe", 
	"NVIDIA Share.exe", 
	"RadeonSoftware.exe", 
]
var debug: bool = true

var check_thread: Thread = null
var manipulation_detected: bool = false
var thread_running: bool = false

func _ready() -> void :
	self.pause_mode = Node.PAUSE_MODE_PROCESS



	start_debug_cheat_checks_thread()
	var timer = Timer.new()
	timer.pause_mode = Node.PAUSE_MODE_PROCESS
	timer.wait_time = 5.0
	timer.one_shot = false
	timer.autostart = true
	add_child(timer)
	timer.connect("timeout", self, "check_for_manipulation")

func _process(_delta: float) -> void :
	if manipulation_detected:
		debug_log(["exit"])
		get_tree().quit()

func start_debug_cheat_checks_thread() -> void :
	if thread_running:
		return
	thread_running = true
	if check_thread != null:
		check_thread.wait_to_finish()
	check_thread = Thread.new()
	check_thread.start(self, "_thread_debug_cheat_checks")

func _thread_debug_cheat_checks() -> bool:
	debug_log(["Thread started"])
	manipulation_detected = not (
		not is_integrity_manipulated() and 
		not is_running_with_cmd_arguments() and 
		not is_dll_injected() and 
		not is_cheat_tool_window_open()
	)
	thread_running = false
	debug_log(["Thread finished with result: ", manipulation_detected])
	return manipulation_detected

func check_for_manipulation() -> void :
	if thread_running:
		return
	thread_running = true
	if check_thread != null:
		check_thread.wait_to_finish()
	check_thread = Thread.new()
	check_thread.start(self, "_thread_check_for_manipulation")

func _thread_check_for_manipulation() -> bool:
	debug_log(["Timer Thread started"])
	manipulation_detected = not (
		not is_dll_injected() and 
		not is_cheat_tool_window_open()
	)
	thread_running = false
	debug_log(["Thread finished with result: ", manipulation_detected])
	return manipulation_detected


func is_integrity_manipulated() -> bool:
	debug_log(["Integrity check started..."])
	var file: = File.new()
	for path in INTEGRITY_CHECKSUMS.keys():
		var FILE = load(path)
		if not file.file_exists(path):
			return true
		file.open(path, File.READ)
		var content = file.get_buffer(file.get_len())
		var hasher = HashingContext.new()
		hasher.start(HashingContext.HASH_SHA256)
		hasher.update(content)
		var hash_bytes = hasher.finish()
		var hashed = hash_bytes.hex_encode()
		if hashed != INTEGRITY_CHECKSUMS[path]:
			
			debug_log(["actual:   ", hashed])
			debug_log(["expected: ", INTEGRITY_CHECKSUMS[path]])
			debug_log(["integrity manipulated: ", path])
			return true
		file.close()
	return false



func is_running_with_cmd_arguments() -> bool:
	debug_log(["CMD check started..."])
	var args = OS.get_cmdline_args()
	debug_log(["CMD arguments: ", args])
	if args.size() > 0:
		if "--betabuild" in args or "--publicbuild" in args:
			return false
		debug_log(["Running with command line arguments:", args])
		return true
	return false



func is_running_under_wine_or_proton() -> bool:
	debug_log(["Wine/Proton check started..."])
	var wine_env = OS.get_environment("WINELOADERNOEXEC")
	var wine_var = OS.get_environment("WINEPREFIX")
	var output = []
	var exit_code = OS.execute("uname", [], true, output)
	var running_wine = false
	if wine_env != "" or wine_var != "":
		running_wine = true
	if output.size() > 0:
		var uname_output = output[0].to_lower()
		if uname_output.find("microsoft") >= 0 or uname_output.find("wine") >= 0:
			running_wine = true
	if get_hardware_id_hash() in wine_ids:
		running_wine = true
	debug_log(["Running in wine or proton: ", running_wine])
	return running_wine



func detect_debugger() -> bool:
	debug_log(["debugger check started..."])
	if not OS.has_feature("editor") and (OS.is_debug_build() or OS.has_feature("debug")):
		debug_log(["detected debugger"])
		return true
	return false



func generate_blacklist_script() -> void :
	var lines = []
	var file = File.new()
	if file.file_exists(INPUT_FILE):
		file.open(INPUT_FILE, File.READ)
		while not file.eof_reached():
			var line = file.get_line().strip_edges()
			if line != "":
				lines.append(line)
		file.close()
	else:
		return
	var gdscript_text = "extends Node\n\n"
	gdscript_text += "const BANNED_IDS = [\n"
	for id in lines:
		gdscript_text += "\t\"" + id + "\",\n"
	gdscript_text += "]\n\n"
	gdscript_text += "func is_banned(hardware_id: String) -> bool:\n"
	gdscript_text += "\treturn hardware_id in BANNED_IDS\n"
	file.open(OUTPUT_FILE, File.WRITE)
	file.store_string(gdscript_text)
	file.close()

func get_hardware_id_hash() -> String:
	var id: String = OS.get_unique_id()
	var salt: String = id.sha256_text()
	var hardware_id: String = (salt + id).sha256_text()
	return hardware_id

func is_device_blacklisted() -> bool:
	debug_log(["Blacklist check started..."])
	if ban_manager.is_banned(get_hardware_id_hash()):
		debug_log(["device is blacklisted"])
		return true
	return false



func is_dll_injected() -> bool:
	debug_log(["Injection check started..."])
	if DLL == null or not DLL.has_method("check_for_dll"):
		debug_log(["DLL unavailable or method missing"])
		return false
	for injection in cheat_dll_injection:
		
		if DLL.check_for_dll(injection):
			debug_log(["Injection detected: ", injection])
			return true
	return false

func is_any_function_hooked() -> bool:
	debug_log(["Function hook check started..."])
	if DLL == null or not DLL.has_method("is_function_hooked"):
		debug_log(["DLL unavailable or method missing"])
		return false
	for hook in critical_hooks:
		if DLL.is_function_hooked(hook["func"], hook["module"]):
			debug_log(["CRITICAL hook detected: %s in %s" % [hook["func"], hook["module"]]])
			return true
	return false

func is_hook_allowed() -> bool:
	var process = DLL.get_current_process_name().to_lower()
	for allowed in hook_whitelist:
		if process == allowed.to_lower():
			return true
	return false



func is_cheat_tool_window_open() -> bool:
	debug_log(["Cheat Tool window check started..."])
	var all_windows = DLL.get_all_window_titles()
	if DLL == null or not DLL.has_method("get_all_window_titles"):
		debug_log(["DLL unavailable or method missing"])
		return false
	for win_title in all_windows:
		var lower_title = win_title.to_lower()
		
		for whitelist_item in window_whitelist:
			if lower_title.find(whitelist_item) >= 0:
				continue
		for cheat_tool in known_critical_cheat_tools:
			if lower_title.find(cheat_tool) >= 0:
				debug_log(["Cheat tool window detected: ", win_title])
				return true
	return false

func is_cheat_tool_window_open_single() -> bool:
	debug_log(["Single Cheat Tool window check started..."])
	if DLL == null or not DLL.has_method("find_window_by_title"):
		debug_log(["DLL unavailable or method missing"])
		return false
	for _tool in known_critical_cheat_tools:
		debug_log(["Cheat Tool: ", _tool])
		if DLL.find_window_by_title(_tool):
			debug_log(["Cheat tool window detected: ", _tool])
			return true
	return false



func debug_log(args) -> void :
	if debug:
		var msg = ""
		for a in args:
			msg += str(a) + " "
		print(msg.strip_edges())
