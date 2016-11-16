library(swedishbirdrecoveries)
context("Dataset content")

test_that("datasets are not empty", {
  expect_gt(nrow(birdrecoveries), 0)
})

test_that("scrape returns data - checklists", {
  expect_gt(nrow(scrape_checklist_falsterbo()), 0)
  expect_gt(nrow(scrape_checklist_norway()), 0)
  expect_gt(nrow(scrape_checklist_ottenby()), 0)
})

test_that("scrape returns data - recoveries", {
  expect_gt(nrow(scrape_recoveries_falsterbo()), 0)
  #expect_gt(nrow(scrape_recoveries_norway()), 0)
  expect_gt(nrow(scrape_recoveries_ottenby()), 0)
})
