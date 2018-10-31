/*
 * DynamicIFrame.java
 *
 * Copyright (C) 2009-12 by RStudio, Inc.
 *
 * Unless you have received this program directly from RStudio pursuant
 * to the terms of a commercial license agreement with RStudio, then
 * this program is licensed to you under the terms of version 3 of the
 * GNU Affero General Public License. This program is distributed WITHOUT
 * ANY EXPRESS OR IMPLIED WARRANTY, INCLUDING THOSE OF NON-INFRINGEMENT,
 * MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. Please refer to the
 * AGPL (http://www.gnu.org/licenses/agpl-3.0.txt) for more details.
 *
 */
package org.rstudio.core.client.widget;

import com.google.gwt.core.client.Scheduler;
import com.google.gwt.core.client.Scheduler.ScheduledCommand;
import com.google.gwt.user.client.ui.Frame;

import org.rstudio.core.client.dom.DocumentEx;
import org.rstudio.core.client.dom.IFrameElementEx;
import org.rstudio.core.client.dom.WindowEx;

public abstract class DynamicIFrame extends Frame
{
   public DynamicIFrame(String url)
   {
      super(url);
      url_ = url;
      pollForLoad();
   }
   
   public DynamicIFrame()
   {
      url_ = null;
      pollForLoad();
   }
   
   @Override
   public void setUrl(String url)
   {
      url_ = url;
      super.setUrl(url);
      pollForLoad();
   }
   
   protected void pollForLoad()
   {
      // wait for the window object to become available
      final Scheduler.RepeatingCommand loadFrame = new Scheduler.RepeatingCommand()
      {
         @Override
         public boolean execute()
         {
            if (getIFrame() == null || getWindow() == null || 
                getDocument() == null)
               return true;
            // if we have a URL, make sure we have a body and the document the
            // URL refers to is fully loaded
            if (url_ != null && getDocument().getURL() == "about:blank" || 
                    getDocument().getBody() == null ||
                    getDocument().getReadyState() != DocumentEx.STATE_COMPLETE)
               return true;
            onFrameLoaded();
            return false;
         }
      };

      // defer an attempt to pull the window object; if it isn't successful, try
      // every 50ms
      Scheduler.get().scheduleDeferred(new ScheduledCommand()
      {
         @Override
         public void execute()
         {
            if (loadFrame.execute()) 
            {
               Scheduler.get().scheduleFixedDelay(loadFrame, 50);
            }
         }
      });
   }

   public IFrameElementEx getIFrame()
   {
      return getElement().cast();
   }

   public WindowEx getWindow()
   {
      return getIFrame().getContentWindow();
   }

   public final DocumentEx getDocument()
   {
      return getWindow().getDocument();
   }
   
   protected abstract void onFrameLoaded();

   private String url_;
}