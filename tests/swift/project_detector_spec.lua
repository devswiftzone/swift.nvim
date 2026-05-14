local detector = require("swift.features.project_detector")

describe("Project Detector", function()
  it("should be able to require the module", function()
    assert.is_not_nil(detector)
  end)

  it("should return none when no project files are found", function()
    local temp_dir = vim.fn.tempname()
    vim.fn.mkdir(temp_dir, "p")

    local old_cwd = vim.fn.getcwd()
    vim.api.nvim_set_current_dir(temp_dir)

    -- Force refresh cache
    local info = detector.get_project_info(true)

    assert.are.same("none", info.type)

    vim.api.nvim_set_current_dir(old_cwd)
    vim.fn.delete(temp_dir, "rf")
  end)
end)
