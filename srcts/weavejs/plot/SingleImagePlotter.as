/* ***** BEGIN LICENSE BLOCK *****
 *
 * This file is part of Weave.
 *
 * The Initial Developer of Weave is the Institute for Visualization
 * and Perception Research at the University of Massachusetts Lowell.
 * Portions created by the Initial Developer are Copyright (C) 2008-2015
 * the Initial Developer. All Rights Reserved.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/.
 * 
 * ***** END LICENSE BLOCK ***** */

namespace weavejs.plot
{
	import Bitmap = flash.display.Bitmap;
	import BitmapData = flash.display.BitmapData;
	import Matrix = flash.geom.Matrix;
	import Point = weavejs.geom.Point;
	import URLRequest = weavejs.net.URLRequest;
	
	import FaultEvent = mx.rpc.events.FaultEvent;
	import ResultEvent = mx.rpc.events.ResultEvent;
	
	import objectWasDisposed = weavejs.api.objectWasDisposed;
	import ILinkableObjectWithNewProperties = weavejs.api.core.ILinkableObjectWithNewProperties;
	import Bounds2D = weavejs.geom.Bounds2D;
	import IPlotter = weavejs.api.ui.IPlotter;
	import LinkableBoolean = weavejs.core.LinkableBoolean;
	import LinkableNumber = weavejs.core.LinkableNumber;
	import LinkableString = weavejs.core.LinkableString;
	import Bounds2D = weavejs.geom.Bounds2D;
	import BitmapText = weavejs.util.BitmapText;
	import BitmapUtils = weavejs.util.BitmapUtils;

	/**
	 * A plotter for drawing a single image onto a tool.
	 */
	export class SingleImagePlotter extends AbstractPlotter implements ILinkableObjectWithNewProperties
	{
		WeaveAPI.ClassRegistry.registerImplementation(IPlotter, SingleImagePlotter, "Single image");
		
		public constructor()
		{
			this.addSpatialDependencies(
				this.dataX,
				this.dataY,
				this.dataWidth,
				this.dataHeight,
				this.useImageSize,
				this.horizontalAlign,
				this.verticalAlign
			);
		}
		
		public set defaultImage(value:BitmapData):void
		{
			if (_bitmapData == BitmapUtils.MISSING_IMAGE || _bitmapData == _defaultImage)
				_bitmapData = value;
			_defaultImage = value;
		}
		
		private _defaultImage:BitmapData;
		
		// these vars store info on the image
		private _bitmapData:BitmapData = BitmapUtils.MISSING_IMAGE;
		private _imgScreenBounds:Bounds2D = new Bounds2D();
		private _imgDataBounds:Bounds2D = new Bounds2D();
		
		private _tempMatrix:Matrix = new Matrix();
		private _tempPoint:Point = new Point();
		
		/**
		 * The URL of the image to download.
		 */
		public imageURL:LinkableString = Weave.linkableChild(this, LinkableString);
		
		public dataX:LinkableNumber = Weave.linkableChild(this, LinkableNumber);
		public dataY:LinkableNumber = Weave.linkableChild(this, LinkableNumber);
		public dataWidth:LinkableNumber = Weave.linkableChild(this, LinkableNumber);
		public dataHeight:LinkableNumber = Weave.linkableChild(this, LinkableNumber);
		public useImageSize:LinkableBoolean = Weave.linkableChild(this, new LinkableBoolean(false));

		public horizontalAlign:LinkableString = Weave.linkableChild(this, new LinkableString(BitmapText.HORIZONTAL_ALIGN_CENTER, verifyHAlign));
		public verticalAlign:LinkableString = Weave.linkableChild(this, new LinkableString(BitmapText.VERTICAL_ALIGN_MIDDLE, verifyVAlign));
		
		private verifyHAlign(value:string):boolean
		{
			return value == BitmapText.HORIZONTAL_ALIGN_LEFT
				|| value == BitmapText.HORIZONTAL_ALIGN_CENTER
				|| value == BitmapText.HORIZONTAL_ALIGN_RIGHT;
		}
		private verifyVAlign(value:string):boolean
		{
			return value == BitmapText.VERTICAL_ALIGN_TOP
				|| value == BitmapText.VERTICAL_ALIGN_MIDDLE
				|| value == BitmapText.VERTICAL_ALIGN_BOTTOM;
		}
		
		private getImageDataWidth():number
		{
			if (useImageSize.value)
				return _bitmapData ? _bitmapData.width : 0;
			return dataWidth.value || 0
		}
		
		private getImageDataHeight():number
		{
			if (useImageSize.value)
				return _bitmapData ? _bitmapData.height : 0;
			return dataHeight.value || 0
		}
		
		/*override*/ public getBackgroundDataBounds(output:Bounds2D):void
		{
			var x:number = dataX.value;
			var y:number = dataY.value;
			var w:number = getImageDataWidth();
			var h:number = getImageDataHeight();
			
			if (horizontalAlign.value == BitmapText.HORIZONTAL_ALIGN_LEFT)
				output.setXRange(x, x + w);
			if (horizontalAlign.value == BitmapText.HORIZONTAL_ALIGN_CENTER)
				output.setCenteredXRange(x, w);
			if (horizontalAlign.value == BitmapText.HORIZONTAL_ALIGN_RIGHT)
				output.setXRange(x - w, x);
			
			if (verticalAlign.value == BitmapText.VERTICAL_ALIGN_TOP)
				output.setYRange(y - h, y);
			if (verticalAlign.value == BitmapText.VERTICAL_ALIGN_MIDDLE)
				output.setCenteredYRange(y, h);
			if (verticalAlign.value == BitmapText.VERTICAL_ALIGN_BOTTOM)
				output.setYRange(y, y + h);
		}
		
		/*override*/ public drawBackground(dataBounds:Bounds2D, screenBounds:Bounds2D, destination:PIXI.Graphics):void
		{
			if (Weave.detectChange(drawBackground, imageURL))
			{
				if (imageURL.value)
				{
					_bitmapData = null;
					WeaveAPI.URLRequestUtils.getContent(this, new URLRequest(imageURL.value), handleImage, handleImageFault, imageURL.value);
				}
				else
				{
					_bitmapData = _defaultImage || BitmapUtils.MISSING_IMAGE;
				}
			}
			
			if (!_bitmapData)
				return;
			
			var tempPoint:Point = new Point(dataX.value, dataY.value);
			dataBounds.projectPointTo(tempPoint, screenBounds);
			
			_tempMatrix.identity();
			
			var xOffset:number = 0;
			var yOffset:number = 0;
			
			switch (horizontalAlign.value)
			{
				case BitmapText.HORIZONTAL_ALIGN_LEFT: // x is aligned to left side of text
					xOffset = 0;
					break;
				case BitmapText.HORIZONTAL_ALIGN_CENTER: 
					xOffset = -_bitmapData.width / 2;
					break;
				case BitmapText.HORIZONTAL_ALIGN_RIGHT: // x is aligned to right side of text
					xOffset = -_bitmapData.width;
					break;
			}
			switch (verticalAlign.value)
			{
				case BitmapText.VERTICAL_ALIGN_TOP: 
					yOffset = 0;
					break;
				
				case BitmapText.VERTICAL_ALIGN_MIDDLE: 
					yOffset = -_bitmapData.height / 2;
					break;
				
				case BitmapText.VERTICAL_ALIGN_BOTTOM:
					yOffset = -_bitmapData.height;
					break;
			}
			_tempMatrix.translate(xOffset, yOffset);
			
			var w:number = getImageDataWidth();
			var h:number = getImageDataHeight();
			var scaleWidth:number = w * screenBounds.getXCoverage() / dataBounds.getXCoverage() / _bitmapData.width;
			var scaleHeight:number = h * screenBounds.getYCoverage() / dataBounds.getYCoverage() / _bitmapData.height;
			
			if (!isFinite(w))
			{
				scaleWidth = 1;
				tempPoint.x = Math.round(tempPoint.x);
			}
			
			if (!isFinite(h))
			{
				scaleHeight = 1;
				tempPoint.y = Math.round(tempPoint.y);
			}
			
			_tempMatrix.scale(scaleWidth, scaleHeight);
			
			_tempMatrix.translate(tempPoint.x, tempPoint.y);
			destination.draw(_bitmapData, _tempMatrix);
		}
		
		private handleImage(event:ResultEvent, url:string):void
		{
			if (objectWasDisposed(this) || url != imageURL.value)
				return;
			
			try
			{
				_bitmapData = Bitmap(event.result).bitmapData;
				Weave.getCallbacks(this).triggerCallbacks();
			}
			catch (e:Error)
			{
				JS.error(e);
			}
		}
		
		private handleImageFault(event:FaultEvent, url:string):void
		{
			if (objectWasDisposed(this) || url != imageURL.value)
				return;
			
			_bitmapData = BitmapUtils.MISSING_IMAGE;
			JS.error(event);
		}
		
		public handleMissingSessionStateProperty(newState:Object, missingProperty:string):void
		{
			if (missingProperty == 'useImageSize')
			{
				if (!imageURL.value)
					imageURL.value = RED_CIRCLE_IMAGE_URL;
			}
		}
		
		
		
		
		
		[Embed(source='/weave/resources/images/red-circle.png')]
		private static _redCircle:Class;
		private static _redCircleUrl:string;
		public static get RED_CIRCLE_IMAGE_URL():string
		{
			var name:string = 'red-circle.png';
			if (!WeaveAPI.URLRequestUtils.getLocalFile(name))
				_redCircleUrl = WeaveAPI.URLRequestUtils.saveLocalFile(name, new _redCircle())
			return _redCircleUrl;
		}
	}
}