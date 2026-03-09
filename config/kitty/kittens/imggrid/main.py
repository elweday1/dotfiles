import httpx
from io import BytesIO
from PIL import Image
from kitty.boss import Boss
from kittens.tui.handler import result_handler

def main(args: list[str]) -> list[bytes]:
    urls = args[1:]
    if not urls:
        return []

    processed_images = []
    with httpx.Client(timeout=10.0, follow_redirects=True) as client:
        for url in urls:
            try:
                r = client.get(url)
                if r.status_code == 200:
                    img = Image.open(BytesIO(r.content))
                    # Resizing here makes the transfer to the terminal instant
                    img.thumbnail((400, 400), Image.Resampling.LANCZOS)
                    with BytesIO() as buf:
                        img.save(buf, format="PNG")
                        processed_images.append(buf.getvalue())
            except Exception:
                continue
    return processed_images

@result_handler(no_ui=True)
def handle_result(args: list[str], images_data: list[bytes], target_window_id: int, boss: Boss) -> None:
    window = boss.window_id_map.get(target_window_id)
    if not window or not images_data:
        return

    for data in images_data:
        # Use the 'icat' kitten directly through the boss 
        # This is more reliable than call_remote_control
        boss.call_remote_control(window, (
            'icat', 
            '--transfer-mode=memory', 
            '--stdin=yes', 
            '--align=left'
        ), stdin=data)
        
        # Physical space for selection/separation
        window.write_to_child("  ")
