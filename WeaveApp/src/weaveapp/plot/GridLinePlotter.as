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
	import Graphics = PIXI.Graphics;
	import Point = weavejs.geom.Point;
	
	import Bounds2D = weavejs.geom.Bounds2D;
	import IPlotter = weavejs.api.ui.IPlotter;
	import LinkableNumber = weavejs.core.LinkableNumber;
	import Bounds2D = weavejs.geom.Bounds2D;
	import LinkableBounds2D = weavejs.geom.LinkableBounds2D;
	import SolidLineStyle = weavejs.plot.SolidLineStyle;

	export class GridLinePlotter extends AbstractPlotter
	{
		public constructor()
		{
			this.lineStyle.caps.defaultValue.value = CapsStyle.NONE;
			this.addSpatialDependencies(this.bounds);
		}
		
		public lineStyle:SolidLineStyle = Weave.linkableChild(this, SolidLineStyle);
		
		public bounds:LinkableBounds2D = Weave.linkableChild(this, LinkableBounds2D);
		public xInterval:LinkableNumber = Weave.linkableChild(this, LinkableNumber);
		public yInterval:LinkableNumber = Weave.linkableChild(this, LinkableNumber);
		public xOffset:LinkableNumber = Weave.linkableChild(this, LinkableNumber);
		public yOffset:LinkableNumber = Weave.linkableChild(this, LinkableNumber);
		
		private tempPoint:Point = new Point();
		private lineBounds:Bounds2D = new Bounds2D();
		
		/*override*/ public getBackgroundDataBounds(output:Bounds2D):void
		{
			this.bounds.copyTo(output);
		}
		
		/*override*/ public drawBackground(dataBounds:Bounds2D, screenBounds:Bounds2D, destination:Graphics):void
		{
			var graphics:Graphics = tempShape.graphics;
			graphics.clear();
			this.lineStyle.beginLineStyle(null, graphics);
			
			this.bounds.copyTo(this.lineBounds);

			// find appropriate bounds for lines
			var xMin:number = this.numericMax(this.lineBounds.getXNumericMin(), dataBounds.getXNumericMin());
			var yMin:number = this.numericMax(this.lineBounds.getYNumericMin(), dataBounds.getYNumericMin());
			var xMax:number = this.numericMin(this.lineBounds.getXNumericMax(), dataBounds.getXNumericMax());
			var yMax:number = this.numericMin(this.lineBounds.getYNumericMax(), dataBounds.getYNumericMax());
			
			// x
			if (yMin < yMax)
			{
				var x0:number = this.xOffset.value || 0;
				var dx:number = Math.abs(this.xInterval.value);
				var xScale:number = dataBounds.getXCoverage() / screenBounds.getXCoverage();
				
				if (xMin < xMax && ((xMin - x0) % dx == 0 || dx == 0))
					this.drawLine(xMin, yMin, xMin, yMax, graphics, dataBounds, screenBounds);
				
				if (dx > xScale) // don't draw sub-pixel intervals
				{
					var xStart:number = xMin - (xMin - x0) % dx;
					if (xStart <= xMin)
						xStart += dx;
					for (var ix:int = 0, x:number = xStart; x < xMax; x = xStart + dx * ++ix)
						this.drawLine(x, yMin, x, yMax, graphics, dataBounds, screenBounds);
				}
				else if (isFinite(this.xOffset.value) && xMin < x0 && x0 < xMax)
					this.drawLine(x0, yMin, x0, yMax, graphics, dataBounds, screenBounds);
				
				if (xMin <= xMax && ((xMax - x0) % dx == 0 || dx == 0))
					this.drawLine(xMax, yMin, xMax, yMax, graphics, dataBounds, screenBounds);
			}
			
			// y
			if (xMin < xMax)
			{
				var y0:number = this.yOffset.value || 0;
				var dy:number = Math.abs(this.yInterval.value);
				var yScale:number = dataBounds.getYCoverage() / screenBounds.getYCoverage();
				
				if (yMin < yMax && ((yMin - y0) % dy == 0 || dy == 0))
					this.drawLine(xMin, yMin, xMax, yMin, graphics, dataBounds, screenBounds);
				
				if (dy > yScale) // don't draw sub-pixel intervals
				{
					var yStart:number = yMin - (yMin - y0) % dy;
					if (yStart <= yMin)
						yStart += dy;
					for (var iy:int = 0, y:number = yStart; y < yMax; y = yStart + dy * ++iy)
						this.drawLine(xMin, y, xMax, y, graphics, dataBounds, screenBounds);
				}
				else if (isFinite(this.yOffset.value) && yMin < y0 && y0 < yMax)
					this.drawLine(xMin, y0, xMax, y0, graphics, dataBounds, screenBounds);
				
				if (yMin <= yMax && ((yMax - y0) % dy == 0 || dy == 0))
					this.drawLine(xMin, yMax, xMax, yMax, graphics, dataBounds, screenBounds);
			}
			
			// flush buffer
			destination.draw(tempShape);
		}
		
		private numericMin(userValue:number, systemValue:number):number
		{
			return userValue < systemValue ? userValue : systemValue; // if userValue is NaN, returns systemValue
		}
		
		private numericMax(userValue:number, systemValue:number):number
		{
			return userValue > systemValue ? userValue : systemValue; // if userValue is NaN, returns systemValue
		}
		
		private drawLine(xMin:number, yMin:number, xMax:number, yMax:number, graphics:Graphics, dataBounds:Bounds2D, screenBounds:Bounds2D):void
		{
			this.tempPoint.x = xMin;
			this.tempPoint.y = yMin;
			dataBounds.projectPointTo(this.tempPoint, screenBounds);
			graphics.moveTo(this.tempPoint.x, this.tempPoint.y);
			
			this.tempPoint.x = xMax;
			this.tempPoint.y = yMax;
			dataBounds.projectPointTo(this.tempPoint, screenBounds);
			graphics.lineTo(this.tempPoint.x, this.tempPoint.y);
		}
		
		//////////////////////////////////////////////////////////////////////////////////////////////
		// backwards compatibility
		
		/*[Deprecated] public set interval(value:number):void { handleDeprecated('interval', value); }
		[Deprecated] public set start(value:number):void { handleDeprecated('start', value); }
		[Deprecated] public set end(value:number):void { handleDeprecated('end', value); }
		[Deprecated] public set horizontal(value:boolean):void { handleDeprecated('alongXAxis', !value); }
		[Deprecated] public set alongXAxis(value:boolean):void { handleDeprecated('alongXAxis', value); }
		private _deprecated:Object;
		private handleDeprecated(name:string, value:any):void
		{
			if (!_deprecated)
				_deprecated = {};
			_deprecated[name] = value;
			
			for each (name in ['start','end','alongXAxis','interval'])
				if (!_deprecated.hasOwnProperty(name))
					return;
			
			if (_deprecated['alongXAxis'])
			{
				xInterval.value = _deprecated['interval'];
				xOffset.value = _deprecated['start'];
				bounds.setBounds(_deprecated['start'], NaN, _deprecated['end'], NaN);
			}
			else
			{
				yInterval.value = _deprecated['interval'];
				yOffset.value = _deprecated['start'];
				bounds.setBounds(NaN, _deprecated['start'], NaN, _deprecated['end']);
			}
			_deprecated = null;
		}*/
	}

	WeaveAPI.ClassRegistry.registerImplementation(IPlotter, GridLinePlotter, "Grid lines");
}

