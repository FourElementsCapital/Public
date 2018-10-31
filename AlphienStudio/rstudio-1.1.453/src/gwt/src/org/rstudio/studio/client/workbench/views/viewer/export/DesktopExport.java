/*
 * DesktopExport.java
 *
 * Copyright (C) 2009-12 by RStudio, Inc.
 *
 * This program is licensed to you under the terms of version 3 of the
 * GNU Affero General Public License. This program is distributed WITHOUT
 * ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING THOSE OF NON-INFRINGEMENT,
 * MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. Please refer to the
 * AGPL (http://www.gnu.org/licenses/agpl-3.0.txt) for more details.
 *
 */

package org.rstudio.studio.client.workbench.views.viewer.export;

import org.rstudio.core.client.BrowseCap;
import org.rstudio.core.client.Rectangle;
import org.rstudio.core.client.dom.ElementEx;
import org.rstudio.core.client.widget.Operation;
import org.rstudio.core.client.widget.OperationWithInput;
import org.rstudio.studio.client.application.Desktop;
import org.rstudio.studio.client.workbench.exportplot.ExportPlotSizeEditor;

import com.google.gwt.core.client.Scheduler;
import com.google.gwt.core.client.Scheduler.ScheduledCommand;
import com.google.gwt.user.client.Command;

public class DesktopExport
{
   private static final native double getSafariZoomFactor() /*-{
      
      // use outerWidth, innerWidth when available
      var outerWidth = $wnd.outerWidth;
      var innerWidth = $wnd.innerWidth;
      if (outerWidth && innerWidth)
         return outerWidth / innerWidth;
         
      // fall back to document width
      var docWidth = $doc.width;
      var clientWidth = $doc.body.clientWidth;
      if (docWidth && clientWidth)
         return docWidth / clientWidth;
         
      // assume no zoom if we failed to discover
      return 1;
   }-*/;
   
   public static void export(final ExportPlotSizeEditor sizeEditor,
                             final OperationWithInput<Rectangle> exporter,
                             final Operation onCompleted)
   {
      sizeEditor.prepareForExport(new Command() {

         @Override
         public void execute()
         {
            // hide gripper
            sizeEditor.setGripperVisible(false);
            
            // get zoom level
            double zoomLevel = BrowseCap.isMacintoshDesktop()
                  ? getSafariZoomFactor()
                  : Desktop.getFrame().getZoomLevel();
            
            // get the preview iframe rect
            ElementEx iframe = sizeEditor.getPreviewIFrame().<ElementEx>cast();
            final Rectangle viewerRect = new Rectangle(
                   (int) Math.ceil(zoomLevel * iframe.getClientLeft()),
                   (int) Math.ceil(zoomLevel * iframe.getClientTop()),
                   (int) Math.ceil(zoomLevel * iframe.getClientWidth()),
                   (int) Math.ceil(zoomLevel * iframe.getClientHeight())).inflate(-1);
            
            // perform the export
            Scheduler.get().scheduleDeferred(new ScheduledCommand() {
               @Override
               public void execute()
               {
                  exporter.execute(viewerRect);
                  
                  // show gripper
                  sizeEditor.setGripperVisible(true);
                  
                  // call onCompleted
                  if (onCompleted != null)
                     onCompleted.execute();
               }
            });
         }   
      });
     
   }
}