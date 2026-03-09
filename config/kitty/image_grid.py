import base64
from io import BytesIO
from PIL import Image
from kitty.boss import Boss
from kittens.tui.handler import result_handler

def main(args: list[str]) -> list[str]:
    # pass image paths through
    return args

@result_handler(no_ui=True)
def handle_result(args: list[str], paths: list[str], target_window_id: int, boss: Boss) -> None:
    w = boss.window_id_map.get(target_window_id)
    if w is None:
        return

    for path in paths:
        img = Image.open(path)
        img.thumbnail((300, 300))

        buf = BytesIO()
        img.save(buf, format="PNG")
        payload = base64.b64encode(buf.getvalue()).decode()

        w.write_to_child(
            f"\033_Ga=T,f=100,q=2;{payload}\033\\\n\n"
        )

