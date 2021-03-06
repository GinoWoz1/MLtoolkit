plot_mod_results <- function(data, mod_names = NULL, plot_cols = NULL, plot_rows = NULL, conf_int95 = FALSE) {
  if (class(data)[1] == "list") {
    if (is.null(mod_names)) {
      stop("Please provide the model names.")
    }

    data <- mult_mod_results(data, mod_names)
  }

  if ("Resample" %in% colnames(data)) {
    data <- dplyr::select(data, -Resample)
  }

  data <- tidyr::gather(data, Metric, Value, -Model)
  data$Metric <- forcats::fct_inorder(data$Metric)
  data$Model <- forcats::fct_inorder(data$Model)

  if (isFALSE(conf_int95)) {
    ggplot2::ggplot(data, aes(Model, Value)) +
      ggplot2::geom_boxplot(fill = "lightgray") +
      ggplot2::facet_wrap(~Metric, scales = "free_y", ncol = plot_cols, nrow = plot_rows) +
      ggplot2::stat_summary(fun.y = "mean", geom = "point", shape = 23, fill = "red") +
      ggplot2::labs(title = "Model Performance Comparison") +
      ggplot2::theme_light() +
      ggplot2::theme(axis.title.x = element_blank(),
                     strip.text.x = element_text(color = "black", size = rel(1.1)),
                     strip.background = element_blank())
  } else if (isTRUE(conf_int95)) {
    ggplot2::ggplot(data, aes(Model, Value)) +
      ggplot2::geom_boxplot(fill = "lightgray") +
      ggplot2::facet_wrap(~Metric, scales = "free_y", ncol = plot_cols, nrow = plot_rows) +
      ggplot2::stat_summary(fun.data = mean_se, geom = "errorbar",
                            color = "red", width = 0.33, fun.args = list(mult = 1.96)) +
      ggplot2::stat_summary(fun.y = "mean", geom = "point", shape = 23, fill = "red") +
      ggplot2::labs(title = "Model Performance Comparison") +
      ggplot2::theme_light() +
      ggplot2::theme(axis.title.x = element_blank(),
                     strip.text.x = element_text(color = "black", size = rel(1.1)),
                     strip.background = element_blank())
  } else {
    stop("The argument conf_int95 can take the values TRUE or FALSE only.")
  }
}
