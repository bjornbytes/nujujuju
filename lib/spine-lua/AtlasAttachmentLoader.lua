-------------------------------------------------------------------------------
-- Spine Runtimes Software License
-- Version 2.1
-- 
-- Copyright (c) 2013, Esoteric Software
-- All rights reserved.
-- 
-- You are granted a perpetual, non-exclusive, non-sublicensable and
-- non-transferable license to install, execute and perform the Spine Runtimes
-- Software (the "Software") solely for internal use. Without the written
-- permission of Esoteric Software (typically granted by licensing Spine), you
-- may not (a) modify, translate, adapt or otherwise create derivative works,
-- improvements of the Software or develop new applications using the Software
-- or (b) remove, delete, alter or obscure any trademarks or any copyright,
-- trademark, patent or other intellectual property or proprietary rights
-- notices on or in the Software, including any copy thereof. Redistributions
-- in binary or source form must include this license and terms.
-- 
-- THIS SOFTWARE IS PROVIDED BY ESOTERIC SOFTWARE "AS IS" AND ANY EXPRESS OR
-- IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
-- MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
-- EVENT SHALL ESOTERIC SOFTARE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
-- SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
-- PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
-- OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
-- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
-- OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
-- ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-------------------------------------------------------------------------------

local RegionAttachment = require 'lib/spine-lua/RegionAttachment'
local BoundingBoxAttachment = require "lib/spine-lua/BoundingBoxAttachment"

local AtlasAttachmentLoader = {}

function AtlasAttachmentLoader.new(atlas)
  local self = {
    atlas = atlas
  }

  function self:newRegionAttachment(skin, name, path)
    local region = self.atlas:findRegion(name)
    if not region then error('Region "' .. name .. '" not found in atlas "' .. path .. '"') end
    local attachment = RegionAttachment.new(name)
    attachment.rendererObject = region
    attachment.regionOffsetX = region.offsetX
    attachment.regionOffsetY = region.offsetY
    attachment.uvs[1] = region.u
    attachment.uvs[2] = region.v
    attachment.uvs[3] = region.u2
    attachment.uvs[4] = region.v2
    attachment.regionX = region.x
    attachment.regionY = region.y
    attachment.regionWidth = region.width
    attachment.regionHeight = region.height
    attachment.regionOriginalWidth = region.originalWidth
    attachment.regionOriginalHeight = region.originalHeight
    return attachment
  end

  function self:newBoundingBoxAttachment(skin, name, path)
		return BoundingBoxAttachment.new(name)
  end

  return self
end

return AtlasAttachmentLoader
