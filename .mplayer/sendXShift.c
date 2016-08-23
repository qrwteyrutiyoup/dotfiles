/* https://bugzilla.gnome.org/show_bug.cgi?id=579430#c13 */
#include <stdio.h>
#include <stdlib.h>

#include <X11/Xlib.h>
#include <X11/extensions/XTest.h>

int main()
{
	Display *dpy;

	dpy = XOpenDisplay(NULL);

	if (!dpy) {
		printf("Xtest not supported\n");
		XCloseDisplay(dpy);
		exit(1);
	}

	// shift down
	XTestFakeKeyEvent(dpy, 0x32, True, CurrentTime);
	// shift up
	XTestFakeKeyEvent(dpy, 0x32, False, CurrentTime);

	XCloseDisplay(dpy);
    return 0;
}

