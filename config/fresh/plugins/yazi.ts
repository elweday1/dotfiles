/// <reference path="../types/fresh.d.ts" />

const YAZI_CONFIG = "/home/deck/.config/yazi-fresh";
const YAZI_OPEN_FILE = "/tmp/fresh-yazi-selection.txt";
let yaziTerminalId: number | null = null;
let yaziBufferId: number | null = null;
let yaziSplitId: number | null = null;
let originalSplitId: number | null = null;

async function checkForYaziFile(): Promise<void> {
  if (yaziTerminalId === null) return;
  
  try {
    const result = await editor.spawnProcess("cat", [YAZI_OPEN_FILE]);
    const content = result.stdout.trim();
    
    if (content && content.length > 0 && !content.startsWith("#")) {
      editor.debug("Yazi: Opening file: " + content);
      
      await editor.spawnProcess("sh", ["-c", "echo '# ready' > " + YAZI_OPEN_FILE]);
      
      if (yaziTerminalId !== null) {
        editor.closeTerminal(yaziTerminalId);
        yaziTerminalId = null;
      }
      
      editor.setStatus("Opening: " + content);
      editor.openFile(content, 0, 0);
      
      if (originalSplitId !== null) {
        editor.focusSplit(originalSplitId);
      }
    }
  } catch (e) {
  }
}

globalThis.pollYaziFile = function(): void {
  checkForYaziFile();
};

globalThis.openYazi = async function(): Promise<void> {
  originalSplitId = editor.getActiveSplitId();
  
  const bufferId = editor.getActiveBufferId();
  let targetDir = ".";

  if (bufferId) {
    const bufferPath = editor.getBufferPath(bufferId);
    if (bufferPath) {
      const lastSlash = bufferPath.lastIndexOf("/");
      if (lastSlash > 0) {
        targetDir = bufferPath.substring(0, lastSlash);
      }
    }
  }

  await editor.spawnProcess("sh", ["-c", "echo '# ready' > " + YAZI_OPEN_FILE]);
  
  editor.setStatus("Opening yazi...");

  const term = await editor.createTerminal({
    cwd: targetDir,
    direction: "vertical",
    ratio: 0.2,
    focus: true
  });

  yaziTerminalId = term.terminalId;
  yaziBufferId = term.bufferId;
  yaziSplitId = term.splitId;

  editor.sendTerminalInput(term.terminalId, "YAZI_CONFIG_HOME=" + YAZI_CONFIG + " yazi\n");
};

globalThis.closeYazi = function(): void {
  if (yaziTerminalId !== null) {
    editor.closeTerminal(yaziTerminalId);
    yaziTerminalId = null;
    yaziBufferId = null;
    yaziSplitId = null;
    
    if (originalSplitId !== null) {
      editor.focusSplit(originalSplitId);
    }
  }
};

globalThis.toggleYazi = async function(): Promise<void> {
  if (yaziTerminalId !== null) {
    closeYazi();
  } else {
    await openYazi();
  }
};

editor.registerCommand("%cmd.open_yazi", "Open Yazi file manager", "openYazi", null);
editor.registerCommand("%cmd.close_yazi", "Close Yazi terminal", "closeYazi", null);
editor.registerCommand("%cmd.toggle_yazi", "Toggle Yazi panel", "toggleYazi", null);

editor.on("render_start", "pollYaziFile");

editor.setStatus("Yazi loaded - '%cmd.toggle_yazi'");
