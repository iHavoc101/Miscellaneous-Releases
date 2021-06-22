-- // Constants \\ --
local RunService = game:GetService("RunService")

-- [ Modules ] --
local MaidModule = loadstring(game:HttpGet("https://raw.githubusercontent.com/Quenty/NevermoreEngine/version2/Modules/Shared/Events/Maid.lua"))()

-- [ LocalPlayer ] --
local Camera = workspace.CurrentCamera

-- // Variables \\ --
local MakeCFrame, MakeVector3, WorldToViewportPoint, ClampNumber = CFrame.new, Vector3.new, Camera.WorldToViewportPoint, math.clamp
local MakeDrawing = Drawing.new

-- // Functions \\ --
local function FetchViewportPoint(Position)
    local ViewportPoint, OnScreen = WorldToViewportPoint(Camera, Position)
    return Vector2.new(ViewportPoint.X, ViewportPoint.Y)
end

local function FetchSurfaces(CoordinateFrame, Size)
    local Surfaces = {
        (CoordinateFrame * MakeCFrame(-Size.X, Size.Y, -Size.Z)).Position,
        (CoordinateFrame * MakeCFrame(-Size.X, Size.Y, Size.Z)).Position,
        (CoordinateFrame * MakeCFrame(Size.X, Size.Y, Size.Z)).Position,
        (CoordinateFrame * MakeCFrame(Size.X, Size.Y, -Size.Z)).Position,
        (CoordinateFrame * MakeCFrame(-Size.X, -Size.Y, -Size.Z)).Position,
        (CoordinateFrame * MakeCFrame(-Size.X, -Size.Y, Size.Z)).Position,
        (CoordinateFrame * MakeCFrame(Size.X, -Size.Y, Size.Z)).Position,
        (CoordinateFrame * MakeCFrame(Size.X, -Size.Y, -Size.Z)).Position
    }

    return {
        UpperSurface = {Surfaces[1], Surfaces[2], Surfaces[3], Surfaces[4]},
        LowerSurface = {Surfaces[5], Surfaces[6], Surfaces[7], Surfaces[8]},
        SideSurface1 = {Surfaces[1], Surfaces[2], Surfaces[6], Surfaces[5]},
        SideSurface2 = {Surfaces[3], Surfaces[4], Surfaces[8], Surfaces[7]},
        SideSurface3 = {Surfaces[2], Surfaces[3], Surfaces[7], Surfaces[6]},
        SideSurface4 = {Surfaces[1], Surfaces[4], Surfaces[8], Surfaces[5]}
    }
end

local function FetchViewportPoints(CoordinateFrame, Size)
    Size /= 2
    local Surfaces = {
        FetchViewportPoint((CoordinateFrame * MakeCFrame(-Size.X, Size.Y, -Size.Z)).Position),
        FetchViewportPoint((CoordinateFrame * MakeCFrame(-Size.X, Size.Y, Size.Z)).Position),
        FetchViewportPoint((CoordinateFrame * MakeCFrame(Size.X, Size.Y, Size.Z)).Position),
        FetchViewportPoint((CoordinateFrame * MakeCFrame(Size.X, Size.Y, -Size.Z)).Position),
        FetchViewportPoint((CoordinateFrame * MakeCFrame(-Size.X, -Size.Y, -Size.Z)).Position),
        FetchViewportPoint((CoordinateFrame * MakeCFrame(-Size.X, -Size.Y, Size.Z)).Position),
        FetchViewportPoint((CoordinateFrame * MakeCFrame(Size.X, -Size.Y, Size.Z)).Position),
        FetchViewportPoint((CoordinateFrame * MakeCFrame(Size.X, -Size.Y, -Size.Z)).Position)
    }

    return {
        UpperSurface = {Surfaces[1], Surfaces[2], Surfaces[3], Surfaces[4]},
        LowerSurface = {Surfaces[5], Surfaces[6], Surfaces[7], Surfaces[8]},
        SideSurface1 = {Surfaces[1], Surfaces[2], Surfaces[6], Surfaces[5]},
        SideSurface2 = {Surfaces[3], Surfaces[4], Surfaces[8], Surfaces[7]},
        SideSurface3 = {Surfaces[2], Surfaces[3], Surfaces[7], Surfaces[6]},
        SideSurface4 = {Surfaces[1], Surfaces[4], Surfaces[8], Surfaces[5]}
    }
end

-- // Main Module \\ --
local MainModule = {}
MainModule.ClassName = "BoxHandleAdornment"
MainModule.__index = MainModule

function MainModule.new()
    local BoxHandleAdornment = {
        Name            = "BoxHandleAdornment",
        Visible         = true,
        Filled          = false,
        Outlined        = true,
        Color3          = Color3.new(1, 1, 1),
        Transparency    = 0,
        Adornee         = nil,
        CFrame          = MakeCFrame(),
        Size            = MakeVector3(),

        _Maid           = MaidModule.new(),
        _Drawings       = {
            UpperSurface = MakeDrawing("Quad");
            LowerSurface = MakeDrawing("Quad");
            SideSurface1 = MakeDrawing("Quad");
            SideSurface2 = MakeDrawing("Quad");
            SideSurface3 = MakeDrawing("Quad");
            SideSurface4 = MakeDrawing("Quad");
        }
    }

    BoxHandleAdornment._Maid:GiveTask(RunService.RenderStepped:Connect(function()
        local ViewportPoints;
        local Adornee = BoxHandleAdornment.Adornee
        if not Adornee then
            ViewportPoints = FetchViewportPoints(BoxHandleAdornment.CFrame, BoxHandleAdornment.Size)
        elseif typeof(Adornee) == "Instance" then
            if Adornee:IsA("BasePart") then
                ViewportPoints = FetchViewportPoints(Adornee.CFrame, Adornee.Size)
            elseif Adornee:IsA("Model") then
                ViewportPoints = FetchViewportPoints(Adornee:GetBoundingBox())
            end
        end

        local Distance = (Camera.CFrame.Position - BoxHandleAdornment.CFrame.Position).Magnitude
        for i,v in pairs(BoxHandleAdornment._Drawings) do
            v.Visible = BoxHandleAdornment.Visible
            v.Filled = BoxHandleAdornment.Filled
            v.Color = BoxHandleAdornment.Color3
            v.Transparency = ClampNumber(1 - BoxHandleAdornment.Transparency, 0, 1)
            v.Thickness = ClampNumber(Distance * 0.01, 0.25, 1)

            local Surface = ViewportPoints[i]
            if Surface then
                v.PointA = Surface[1]
                v.PointB = Surface[2]
                v.PointC = Surface[3]
                v.PointD = Surface[4]
            end
        end
    end))

    return setmetatable(BoxHandleAdornment, MainModule)
end

function MainModule:IsA(Class)
    return Class == self.ClassName
end

function MainModule:Clone()
    local Clone = MainModule.new()
    for i,v in pairs(self) do
        if not i:match("^_") then
            Clone[i] = v
        end
    end
    return Clone
end

function MainModule:Destroy()
    for i,v in pairs(self._Drawings) do
        v:Remove()
    end
    self._Maid:Destroy()
end

local e = MainModule.new()
e.Adornee = workspace.ihavoc101

return MainModule
