// Pressione ESC para pular a abertura

if (keyboard_check_pressed(vk_escape)) {
    video_close();
    room_goto(rm_cozinha);
}