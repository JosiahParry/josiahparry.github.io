josi_theme <- function (base_size = 11, base_family = "") 
{
  half_line <- base_size/2
  theme(line = element_line(colour = "black", size = 0.5, linetype = 1, lineend = "butt"), 
        rect = element_rect(fill = "#282825", colour = "black", size = 0.5, linetype = 1), 
        text = element_text(family = base_family, face = "plain", colour = "#fffef4", 
                            size = base_size, lineheight = 0.9, hjust = 0.5, vjust = 0.5, angle = 0, 
                            margin = margin(), debug= FALSE), 
        # AXES
        axis.line = element_line(), 
        axis.line.x = element_blank(), 
        axis.line.y = element_blank(), 
        axis.text = element_text(size = rel(0.8), colour = "#565647"), #92466b 
        axis.text.x = element_text(margin = margin(t = 0.8 * half_line/2), vjust = 1), 
        axis.text.y = element_text(margin = margin(r = 0.8 * half_line/2), hjust = 1), 
        axis.ticks = element_line(colour = "#706b5f"),
        axis.ticks.length = unit(half_line/2, "pt"), 
        axis.title = element_text(face = "bold", colour = "#fffeed"),
        axis.title.x = element_text(margin = margin(t = 0.8 * half_line, b = 0.8 * half_line/2)), 
        axis.title.y = element_text(angle = 90, margin = margin(r = 0.8 * half_line, l = 0.8 * half_line/2)),
        # LEGEND
        legend.background = element_rect(colour = NA), 
        legend.spacing = unit(0.2, "cm"), 
        legend.key = element_rect(fill = "grey95", colour = "white"), 
        legend.key.size = unit(1.2, "lines"), 
        legend.key.height = NULL, 
        legend.key.width = NULL, 
        legend.text = element_text(size = rel(0.8)), 
        legend.text.align = NULL, 
        legend.title = element_text(hjust = 0), 
        legend.title.align = NULL, legend.position = "right", 
        legend.direction = NULL, legend.justification = "center", 
        legend.box = NULL, 
        # PANEL 
        panel.background = element_rect(fill = "#474741", colour = NA),  #peach ffc9b5 #baby blue d6ddee
        panel.border = element_blank(), 
        panel.grid.major = element_line(colour = "#474741", size = 0.2), 
        panel.grid.minor = element_line(colour = "#474741", size = 0.15), 
        panel.spacing = unit(half_line, "pt"), 
        panel.spacing.x = NULL, 
        panel.spacing.y = NULL, 
        panel.ontop = FALSE, 
        # FACETS
        strip.background = element_rect(fill = "#383732", colour = NA), 
        strip.text = element_text(size = rel(0.8)), 
        strip.text.x = element_text(margin = margin(t = half_line,  b = half_line)), 
        strip.text.y = element_text(angle = -90, margin = margin(l = half_line, r = half_line)), 
        strip.switch.pad.grid = unit(0.1, "cm"), 
        strip.switch.pad.wrap = unit(0.1, "cm"), 
        # OVERALL PLOT
        plot.background = element_rect(colour = "#232320"), 
        plot.title = element_text(size = rel(1.3), margin = margin(b = half_line * 1.2), 
                                  face = "bold.italic", vjust = .35),
        plot.subtitle = element_text(size = rel(1.15), face = "italic", vjust = 1.75),
        plot.margin = margin(half_line, half_line, half_line, half_line), complete = TRUE)
}
