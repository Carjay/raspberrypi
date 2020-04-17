#include <gst/gst.h>
#include <string>
#include <sstream>

// code converted to c++ and slightly adapted from the original tutorial at
// https://gstreamer.freedesktop.org/documentation/tutorials/basic/hello-world.html?gi-language=c#

int
main (int argc, char *argv[])
{
  GstElement *pipeline;
  GstBus *bus;
  GstMessage *msg;

  // default clip that is streamed directly from the web
  // to play back local clips, use file://localclipname
  std::string url = "https://www.freedesktop.org/software/gstreamer-sdk/data/media/sintel_trailer-480p.webm";
  if(argc > 1) {
    url = argv[1];
  }

  /* Initialize GStreamer */
  gst_init (&argc, &argv);

  std::stringstream s;
  s << "playbin uri=" << url;
  printf("playing back %s\n", s.str().c_str());
  /* Build the pipeline */
  pipeline =
      gst_parse_launch
      (s.str().c_str(),
      NULL);

  /* Start playing */
  gst_element_set_state (pipeline, GST_STATE_PLAYING);

  /* Wait until error or EOS */
  bus = gst_element_get_bus (pipeline);
  msg =
      gst_bus_timed_pop_filtered (bus, GST_CLOCK_TIME_NONE,
      static_cast<GstMessageType>( GST_MESSAGE_ERROR | GST_MESSAGE_EOS));

  /* Free resources */
  if (msg != NULL)
    gst_message_unref (msg);
  gst_object_unref (bus);
  gst_element_set_state (pipeline, GST_STATE_NULL);
  gst_object_unref (pipeline);
  return 0;
}
