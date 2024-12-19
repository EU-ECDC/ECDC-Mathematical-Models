# Creates a plot of forecasts (median + quantile envelope) with past data
# Each location/country is a separate facet/subplot
# Input:
# - data: dataframe of past data with columns, date, location, value
# - forecasts: dataframe of forecasts with columns, date, location, , quantiles, value
# - quantile range: vector of size 2 that defines which inter quantile range you want to show; default is c(0.5, 0.9)
# 
# Output:
# - output figure handle 

plot_data_with_quantiles <- function(data, forecast, quantile_range = c(0.5, 0.9)) {
  # Validate inputs
  if (!all(c("date", "location", "value") %in% names(data))) {
    stop("The first data frame must contain columns: date, location, value.")
  }
  if (!all(c("target_date", "location", "quantiles", "value") %in% names(forecast))) {
    stop("The second data frame must contain columns: target_date, location, quantiles, value.")
  }
  
  # Calculate the lower and upper quantile bounds
  lower_mid_bound <- (1 - quantile_range[1]) / 2
  upper_mid_bound <- 1 - lower_mid_bound
  
  lower_out_bound <- (1 - quantile_range[2]) / 2
  upper_out_bound <- 1 - lower_out_bound
  
  
  # Prepare forecast data for envelopes
  forecast_envelope <- forecast %>%
    # Using the 'abs(value-bound)<1e-10' due to issues in the past with 'value==bound'
    filter( abs(quantiles-lower_mid_bound)<1e-10 | abs(quantiles-upper_mid_bound)<1e-10 |
            abs(quantiles-lower_out_bound)<1e-10 | abs(quantiles-upper_out_bound)<1e-10) %>%
    pivot_wider(names_from = quantiles, values_from = value, names_prefix = "quantile_") %>%
    rename(lower_mid = paste0("quantile_", lower_mid_bound),
           upper_mid = paste0("quantile_", upper_mid_bound),
           lower_out = paste0("quantile_", lower_out_bound),
           upper_out = paste0("quantile_", upper_out_bound),
           )
  
  # Extract median values from forecast
  forecast_median <- forecast %>%
    filter(quantiles == 0.5)
  
  # Filtering before plotting
  countries_forecasts = unique( forecast$location )
  data = data %>% filter(date>max(date)-90,
                         location %in% countries_forecasts)
  
  # Create the plot
  plot <- ggplot() +
    # Add the line plot for the first data frame
    geom_line(data = data, aes(x = date, y = value, color = "Observed"), size = 1) +
    geom_point(data = data, aes(x = date, y = value, color = "Observed"), size = 2) +
    # Add the quantile envelope
    geom_ribbon(data = forecast_envelope, aes(x = target_date, ymin = lower_mid, ymax = upper_mid), fill = 'red', alpha = 0.5) +
    geom_ribbon(data = forecast_envelope, aes(x = target_date, ymin = lower_out, ymax = upper_out), fill = "red", alpha = 0.2) +
    # Add the median line
    geom_point(data = forecast_median, aes(x = target_date, y = value, color = "Forecasts")) +
    geom_line(data = forecast_median, aes(x = target_date, y = value, color = "Forecasts"), size = 1) +
    # Facet by location with free scales
    facet_wrap(~location, scales = "free_y") +
    # Custom colors and labels
    scale_color_manual(values = c("Observed" = "gray", "Forecasts" = "red")) +
    #scale_fill_manual(values = c(QR1 = "blue", QR2 = "red")) +
    # Labels and theme
    labs(title = "Observed Data and Forecasts with Quantile Envelope",
         x = "Date",
         y = "Value",
         color = "Legend",
         fill = "Legend") +
    theme_minimal()
  
  return(plot)
}
