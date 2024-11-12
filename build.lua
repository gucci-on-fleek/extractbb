-- extractbb-lua
-- https://github.com/gucci-on-fleek/extractbb
-- SPDX-License-Identifier: MPL-2.0+
-- SPDX-FileCopyrightText: 2024 Max Chernoff

-- Initialization
module = "extractbb"

local orig_targets = target_list
target_list = {}

-- Tagging
target_list.tag = orig_targets.tag
tagfiles = { "source/*.*", "docs/**/*.*", "README.md" }

function update_tag(name, content, version, date)
    if not version then
        print("No version provided. Exiting")
        os.exit(1)
    end

    if name:match("%.pdf$") then
        return content
    end

    content = content:gsub(
        "(%d%.%d%.%d)([^\n]*)%%%%version",
        version .. "%2%%%%version"
    ):gsub(
        "(%d%d%d%d%-%d%d%-%d%d)([^\n]*)%%%%dashdate",
        date .. "%2%%%%dashdate"
    ):gsub(
        "(%d%d%d%d/%d%d/%d%d)([^\n]*)%%%%slashdate",
        date:gsub("-", "/") .. "%2%%%%slashdate"
    )

    return content
end

-- Bundle
target_list.bundle = {}
target_list.bundle.desc = "Creates the package zipfiles"

function target_list.bundle.func()
    local newzip = require "l3build-zip"
    local tdszipname = module .. ".tds.zip"

    local tdszip = newzip("./" .. tdszipname)
    local ctanzip = newzip("./" .. module .. ".ctan.zip")

    for _, path in ipairs(tree("texmf", "**/*.*")) do
        tdszip:add(
            path.cwd, -- outer
            path.src:sub(3), -- inner
            path.src:match("pdf") -- binary
        )
        ctanzip:add(
            path.cwd, -- outer
            module .. "/" .. basename(path.src), -- inner
            path.src:match("pdf") -- binary
        )
    end

    tdszip:close()

    ctanzip:add("./" .. tdszipname, tdszipname, true)
    ctanzip:add("./" .. "DEPENDS.txt", "DEPENDS.txt", false)
    ctanzip:close()

    return 0
end

-- Documentation
target_list.doc = {}
target_list.doc.desc = "Builds the documentation"

function target_list.doc.func()
    print("Nothing to do!")
end

-- Tests
target_list.check = orig_targets.check
target_list.save = orig_targets.save

os.setenv("diffexe", "git diff --no-index -w --word-diff --text")

testfiledir = "./tests/"
tdsdirs = { ["./texmf"] = "." }
maxprintline = 10000

test_types = {}
test_order = {}

local function add_type(extension)
    test_types[extension] = {
        test = "." .. extension,
        generated = "",
        reference = ".bbox-reference",
        expectation = "." .. extension,
    }
    table.insert(test_order, extension)
end

add_type("jpg")
add_type("pdf")
add_type("png")

function runtest(name, engine, _, ext, _, is_expectation)
    local in_file = testfiledir .. name .. ext
    local out_file = testdir .. "/" .. name .. "." .. engine

    local texlive_extractbb
    if is_expectation then
        texlive_extractbb = "wrapper"
    else
        texlive_extractbb = "scratch"
    end

    local extractbb_flags
    if engine == "bb" then
        extractbb_flags = " -m -O "
    elseif engine == "xbb" then
        extractbb_flags = " -x -O "
    else
        error()
    end

    local code = os.execute(
        os_setenv .. " TEXLIVE_EXTRACTBB=" .. texlive_extractbb ..
        os_concat .. os_setenv .. " SOURCE_DATE_EPOCH=0" ..
        os_concat .. os_setenv .. " TZ=UTC" ..
        os_concat .. os_setenv .. " TEXINPUTS=./texmf//" ..
        os_concat .. os_setenv .. " LUAINPUTS=./texmf//" ..
        os_concat .. " ./source/extractbb-chooser.lua" .. extractbb_flags .. in_file ..
        " > " .. out_file
    )

    -- Post-process
    local file = io.open(out_file, "r")
    local contents = file:read("*a")
    file:close()
    file = io.open(out_file, "w")
    file:write((contents
        :gsub("%%%%Creator:[^\n]*", "%%Creator: [redacted]")
        :gsub("(%d+%.%d%d%d%d%d%d)", function (value)
            return string.format("%.4fX", tonumber(value))
        end)
    ))
    file:close()

    if code ~= 0 then
        error("Failure!")
    end
end

specialformats = { extractbb = {
    bb = {
        binary = "bb"
    },
    xbb = {
        binary = "xbb"
    },
}}

checkengines = { "bb", "xbb" }
checkformat = "extractbb"
forcecheckruns = false
