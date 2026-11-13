
/// @description Finaliza a abertura

var tipo = async_load[? "type"];

if (tipo == "video_end") {

    video_close();

    room_goto(rm_cozinha);
}
