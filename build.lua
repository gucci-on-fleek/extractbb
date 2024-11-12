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

testsuppdir = "./tests/common"
tdsdirs = { ["./texmf"] = "." }
maxprintline = 10000

test_types = {
    bbox = {
        test = ".bbox-in",
        generated = ".bbox-sentinel",
        reference = ".bbox-out",
        rewrite = function(generated, target, engine)
            if engine:match("ebb") then
                os.rename(generated:gsub("%.bbox-sentinel$", ".xbb"), target)
            elseif engine:match("xbb") then
                os.rename(generated:gsub("%.bbox-sentinel$", ".bb"), target)
            else
                error("Unknown engine: " .. engine)
            end
        end,
    },
}

test_order = { "bbox" }

specialformats = { extractbb = {
    wrapper_ebb = {
        binary = os_setenv .. " TEXLIVE_EXTRACTBB=wrapper" .. os_concat "extractbb -m ",
        format = ""
    },
    wrapper_xbb = {
        binary = os_setenv .. " TEXLIVE_EXTRACTBB=wrapper" .. os_concat "extractbb -x ",
        format = ""
    },
    scratch_ebb = {
        binary = os_setenv .. " TEXLIVE_EXTRACTBB=scratch" .. os_concat "extractbb -m ",
        format = ""
    },
    scratch_xbb = {
        binary = os_setenv .. " TEXLIVE_EXTRACTBB=scratch" .. os_concat "extractbb -x ",
        format = ""
    },
}}

checkengines = {
    "wrapper_ebb",
    "wrapper_xbb",
    "scratch_ebb",
    "scratch_xbb",
}
checkformat = "extractbb"
