#!/usr/bin/env texlua
-- extractbb-lua
-- https://github.com/gucci-on-fleek/extractbb
-- SPDX-License-Identifier: MPL-2.0+
-- SPDX-FileCopyrightText: 2024 Max Chernoff
--
-- A wrapper script to allow you to choose which implementation of extractbb to
-- use. Should hopefully be replaced with the ``scratch'' file in TeX Live 2025.

---------------------
--- Configuration ---
---------------------
-- Choose which implementation of extractbb to use.
local DEFAULT = "wrapper"


-----------------
--- Execution ---
-----------------

-- Get the value of the environment variable that decides which version to run.
local env_choice = os.env["TEXLIVE_EXTRACTBB"]

-- Map the choice names to file names.
local choice_mapping = {
    wrapper = kpse.find_file("extractbb-wrapper.lua", "texmfscripts", true),
    scratch = kpse.find_file("extractbb-scratch.lua", "texmfscripts", true),
}

-- Choose the implementation to run.
local choice = choice_mapping[env_choice] or choice_mapping[DEFAULT]

-- And run it.
dofile(choice)
