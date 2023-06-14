#!/bin/bash

plot_LAB_median_MAD_panel(){

  # Set GMT plotting parameters
  gmt gmtset FORMAT_FLOAT_OUT %.8f FONT_LABEL 16p FONT_ANNOT_PRIMARY 14p PS_MEDIA a0 MAP_FRAME_TYPE plain

  mkdir -p ${fold_plot_output}
  fold_plot=${fold_plot_output}/${fold_date}
  mkdir -p ${fold_plot}

  f_plot=${fold_plot}/LAB1200_median_MAD_panel
  ps=${f_plot}.ps
  jpg=${f_plot}.jpg

  proj_map="-JM15c"
  rgn_map="-R112/155/-44/-10"
  rgn_x="-R0/1/0/1"

  grid_type="LAB1200"
  fold_grid=${fold_data_output}/${grid_type}/distribution
  fold_grid_summary=${fold_grid}/summary
  file=${fold_grid_summary}/${grid_type}_median.xyz
  grid=${fold_grid_summary}/${grid_type}_median.grd
  grid_filtered=${fold_grid_summary}/${grid_type}_median_filtered.grd
  rgn_grd="-R109/158.5/-45/-6"
  inc_grd="-I0.1d/0.1d"
  gmt xyz2grd $rgn_grd $inc_grd $file -G$grid
  gmt grdfilter -D4 -Fg400 $grid -G$grid_filtered
  grid=$grid_filtered
  gmt makecpt -T50/300/26+n -Cpolar -D -I -G-0.667/0.667 > litho.cpt
  gmt makecpt -T50/300/26+n -Cpolar -D -I > litho_contour.cpt
  gmt psbasemap $rgn_map $proj_map -B10 -Bg2 -BWSNE -K -X20c -Y40c > $ps
  gmt grdimage $grid -Clitho.cpt $rgn_map $proj_map -E600 -O -K >> $ps
  gmt grdcontour $grid $rgn_map $proj_map -Clitho_contour.cpt -A- -W0.7p,4_2:2p,+cl -O -K >> $ps
  gmt grdcontour $grid $rgn_map $proj_map -C+170 -W1p,4_2:2p -O -K >> $ps
  gmt pscoast $rgn_map $proj_map -Dh -A50000/0/2 -Wthin,black -O -K >> $ps
  gmt psscale -Dx1.5c/-1.3c+w12c/0.25c+e+h -Clitho.cpt -B50f10+l"Median (km)" -O -K >> $ps
  echo "-0.05 0.01 a" | gmt pstext $rgn_x $proj_map -F+f18p+jBL -C+tO -Gwhite -W1p,black -N -O -K >> $ps

  proj_map="-JM15c"
  rgn_map="-R112/155/-44/-10"

  grid_type="LAB1200"
  fold_grid=${fold_data_output}/${grid_type}/distribution
  fold_grid_summary=${fold_grid}/summary
  file=${fold_grid_summary}/${grid_type}_MAD.xyz
  grid=${fold_grid_summary}/${grid_type}_MAD.grd
  grid_filtered=${fold_grid_summary}/${grid_type}_MAD_filtered.grd
  rgn_grd="-R109/158.5/-45/-6"
  inc_grd="-I0.1d/0.1d"
  gmt xyz2grd $rgn_grd $inc_grd $file -G$grid
  gmt grdfilter -D4 -Fg400 $grid -G$grid_filtered
  grid=$grid_filtered
  gmt makecpt -T0/10/0.5 -Ccopper -D -I > litho.cpt
  gmt psbasemap $rgn_map $proj_map -B10 -Bg2 -BWSNE -O -K -Y-17.3c >> $ps
  gmt grdimage $grid -Clitho.cpt $rgn_map $proj_map -E600 -O -K >> $ps
  gmt grdcontour $grid $rgn_map $proj_map -C1 -W0.7p,4_2:2p -O -K >> $ps
  gmt pscoast $rgn_map $proj_map -Dh -A50000/0/2 -Wthin,black -O -K >> $ps
  gmt psscale -Dx1.5c/-1.3c+w12c/0.25c+ef+h -Clitho.cpt -B1f0.5+l"Median absolute deviation (km)" -O -K >> $ps
  echo "-0.05 0.01 b" | gmt pstext $rgn_x $proj_map -F+f18p+jBL -C+tO -Gwhite -W1p,black -N -O -K >> $ps
  gmt psbasemap $rgn_map $proj_map -BWSNE -O >> $ps
  gmt psconvert -Tj -E600c -A0.1c -P -Z $ps

}

plot_LAB_summary(){

  # Set GMT plotting parameters
  gmt gmtset FORMAT_FLOAT_OUT %.8f FONT_LABEL 16p FONT_ANNOT_PRIMARY 14p PS_MEDIA a0 MAP_FRAME_TYPE plain

  mkdir -p ${fold_plot_output}
  fold_plot=${fold_plot_output}/${fold_date}
  mkdir -p ${fold_plot}

  f_plot=${fold_plot}/LAB1200_MAD
  ps=${f_plot}.ps
  jpg=${f_plot}.jpg

  proj_map="-JM15c"
  rgn_map="-R112/155/-44/-10"

  grid_type="LAB1200"
  fold_grid=${fold_data_output}/${grid_type}/distribution
  fold_grid_summary=${fold_grid}/summary
  file=${fold_grid_summary}/${grid_type}_MAD.xyz
  grid=${fold_grid_summary}/${grid_type}_MAD.grd
  grid_filtered=${fold_grid_summary}/${grid_type}_MAD_filtered.grd
  rgn_grd="-R109/158.5/-45/-6"
  inc_grd="-I0.1d/0.1d"
  gmt xyz2grd $rgn_grd $inc_grd $file -G$grid
  gmt grdfilter -D4 -Fg400 $grid -G$grid_filtered
  grid=$grid_filtered
  gmt makecpt -T0/10/0.5 -Ccopper -D -I > litho.cpt
  gmt psbasemap $rgn_map $proj_map -B10 -Bg2 -BWSNE -K -X20c -Y20c > $ps
  gmt grdimage $grid -Clitho.cpt $rgn_map $proj_map -E600 -O -K >> $ps
  gmt grdcontour $grid $rgn_map $proj_map -C1 -W0.7p,4_2:2p -O -K >> $ps
  gmt pscoast $rgn_map $proj_map -Dh -A50000/0/2 -Wthin,black -O -K >> $ps
  gmt psscale -Dx1.5c/-1.5c+w12c/0.25c+ef+h -Clitho.cpt -B1f0.5+l"Median absolute deviation (km)" -O -K >> $ps
  gmt psbasemap $rgn_map $proj_map -BWSNE -O >> $ps
  gmt psconvert -Tj -E600c -A0.1c -P -Z $ps

  f_plot=${fold_plot}/LAB1200_std
  ps=${f_plot}.ps
  jpg=${f_plot}.jpg

  proj_map="-JM15c"
  rgn_map="-R112/155/-44/-10"

  grid_type="LAB1200"
  fold_grid=${fold_data_output}/${grid_type}/distribution
  fold_grid_summary=${fold_grid}/summary
  file=${fold_grid_summary}/${grid_type}_std.xyz
  grid=${fold_grid_summary}/${grid_type}_std.grd
  grid_filtered=${fold_grid_summary}/${grid_type}_std_filtered.grd
  rgn_grd="-R109/158.5/-45/-6"
  inc_grd="-I0.1d/0.1d"
  gmt xyz2grd $rgn_grd $inc_grd $file -G$grid
  gmt grdfilter -D4 -Fg400 $grid -G$grid_filtered
  grid=$grid_filtered
  gmt makecpt -T0/10/0.5 -Ccopper -D -I > litho.cpt
  gmt psbasemap $rgn_map $proj_map -B10 -Bg2 -BWSNE -K -X20c -Y20c > $ps
  gmt grdimage $grid -Clitho.cpt $rgn_map $proj_map -E600 -O -K >> $ps
  gmt grdcontour $grid $rgn_map $proj_map -C1 -W0.7p,4_2:2p -O -K >> $ps
  gmt pscoast $rgn_map $proj_map -Dh -A50000/0/2 -Wthin,black -O -K >> $ps
  gmt psscale -Dx1.5c/-1.5c+w12c/0.25c+ef+h -Clitho.cpt -B1f0.5+l"Standard deviation (km)" -O -K >> $ps
  gmt psbasemap $rgn_map $proj_map -BWSNE -O >> $ps
  gmt psconvert -Tj -E600c -A0.1c -P -Z $ps

  f_plot=${fold_plot}/LAB1200_MAP
  ps=${f_plot}.ps
  jpg=${f_plot}.jpg

  proj_map="-JM15c"
  rgn_map="-R112/155/-44/-10"

  grid_type="LAB1200"
  fold_grid=${fold_data_output}/${grid_type}/MAP
  fold_grid_summary=${fold_grid}
  file=${fold_grid_summary}/FR12_${grid_type}_MAP.txt
  grid=${fold_grid_summary}/${grid_type}_MAP.grd
  grid_filtered=${fold_grid_summary}/${grid_type}_MAP_filtered.grd
  rgn_grd="-R109/158.5/-45/-6"
  inc_grd="-I0.1d/0.1d"
  gmt xyz2grd $rgn_grd $inc_grd $file -G$grid
  gmt grdfilter -D4 -Fg400 $grid -G$grid_filtered
  grid=$grid_filtered
  gmt makecpt -T50/300/26+n -Cpolar -D -I -G-0.667/0.667 > litho.cpt
  gmt makecpt -T50/300/26+n -Cpolar -D -I > litho_contour.cpt
  gmt psbasemap $rgn_map $proj_map -B10 -Bg2 -BWSNE -K -X20c -Y20c > $ps
  gmt grdimage $grid -Clitho.cpt $rgn_map $proj_map -E600 -O -K >> $ps
  gmt grdcontour $grid $rgn_map $proj_map -Clitho_contour.cpt -A- -W0.7p,4_2:2p,+cl -O -K >> $ps
  gmt grdcontour $grid $rgn_map $proj_map -C+170 -W1p,4_2:2p -O -K >> $ps
  gmt pscoast $rgn_map $proj_map -Dh -A50000/0/2 -Wthin,black -O -K >> $ps
  gmt psscale -Dx1.5c/-1.5c+w12c/0.25c+e+h -Clitho.cpt -B50f10+l"Maximum @%2%a posteriori@%0% (km)" -O -K >> $ps
  gmt psbasemap $rgn_map $proj_map -BWSNE -O >> $ps
  gmt psconvert -Tj -E600c -A0.1c -P -Z $ps

  f_plot=${fold_plot}/LAB1200_mean
  ps=${f_plot}.ps
  jpg=${f_plot}.jpg

  proj_map="-JM15c"
  rgn_map="-R112/155/-44/-10"

  grid_type="LAB1200"
  fold_grid=${fold_data_output}/${grid_type}/distribution
  fold_grid_summary=${fold_grid}/summary
  file=${fold_grid_summary}/${grid_type}_mean.xyz
  grid=${fold_grid_summary}/${grid_type}_mean.grd
  grid_filtered=${fold_grid_summary}/${grid_type}_mean_filtered.grd
  rgn_grd="-R109/158.5/-45/-6"
  inc_grd="-I0.1d/0.1d"
  gmt xyz2grd $rgn_grd $inc_grd $file -G$grid
  gmt grdfilter -D4 -Fg400 $grid -G$grid_filtered
  grid=$grid_filtered
  gmt makecpt -T50/300/26+n -Cpolar -D -I -G-0.667/0.667 > litho.cpt
  gmt makecpt -T50/300/26+n -Cpolar -D -I > litho_contour.cpt
  gmt psbasemap $rgn_map $proj_map -B10 -Bg2 -BWSNE -K -X20c -Y20c > $ps
  gmt grdimage $grid -Clitho.cpt $rgn_map $proj_map -E600 -O -K >> $ps
  gmt grdcontour $grid $rgn_map $proj_map -Clitho_contour.cpt -A- -W0.7p,4_2:2p,+cl -O -K >> $ps
  gmt grdcontour $grid $rgn_map $proj_map -C+170 -W1p,4_2:2p -O -K >> $ps
  gmt pscoast $rgn_map $proj_map -Dh -A50000/0/2 -Wthin,black -O -K >> $ps
  gmt psscale -Dx1.5c/-1.5c+w12c/0.25c+e+h -Clitho.cpt -B50f10+l"Mean (km)" -O -K >> $ps
  gmt psbasemap $rgn_map $proj_map -BWSNE -O >> $ps
  gmt psconvert -Tj -E600c -A0.1c -P -Z $ps

  f_plot=${fold_plot}/LAB1200_median
  ps=${f_plot}.ps
  jpg=${f_plot}.jpg

  proj_map="-JM15c"
  rgn_map="-R112/155/-44/-10"

  grid_type="LAB1200"
  fold_grid=${fold_data_output}/${grid_type}/distribution
  fold_grid_summary=${fold_grid}/summary
  file=${fold_grid_summary}/${grid_type}_median.xyz
  grid=${fold_grid_summary}/${grid_type}_median.grd
  grid_filtered=${fold_grid_summary}/${grid_type}_median_filtered.grd
  rgn_grd="-R109/158.5/-45/-6"
  inc_grd="-I0.1d/0.1d"
  gmt xyz2grd $rgn_grd $inc_grd $file -G$grid
  gmt grdfilter -D4 -Fg400 $grid -G$grid_filtered
  grid=$grid_filtered
  gmt makecpt -T50/300/26+n -Cpolar -D -I -G-0.667/0.667 > litho.cpt
  gmt makecpt -T50/300/26+n -Cpolar -D -I > litho_contour.cpt
  gmt psbasemap $rgn_map $proj_map -B10 -Bg2 -BWSNE -K -X20c -Y20c > $ps
  gmt grdimage $grid -Clitho.cpt $rgn_map $proj_map -E600 -O -K >> $ps
  gmt grdcontour $grid $rgn_map $proj_map -Clitho_contour.cpt -A- -W0.7p,4_2:2p,+cl -O -K >> $ps
  gmt grdcontour $grid $rgn_map $proj_map -C+170 -W1p,4_2:2p -O -K >> $ps
  gmt pscoast $rgn_map $proj_map -Dh -A50000/0/2 -Wthin,black -O -K >> $ps
  gmt psscale -Dx1.5c/-1.5c+w12c/0.25c+e+h -Clitho.cpt -B50f10+l"Median (km)" -O -K >> $ps
  gmt psbasemap $rgn_map $proj_map -BWSNE -O >> $ps
  gmt psconvert -Tj -E600c -A0.1c -P -Z $ps

  f_plot=${fold_plot}/LAB1200_pct_5
  ps=${f_plot}.ps
  jpg=${f_plot}.jpg

  proj_map="-JM15c"
  rgn_map="-R112/155/-44/-10"

  grid_type="LAB1200"
  fold_grid=${fold_data_output}/${grid_type}/distribution
  fold_grid_summary=${fold_grid}/summary
  file=${fold_grid_summary}/${grid_type}_pct_5.xyz
  grid=${fold_grid_summary}/${grid_type}_pct_5.grd
  grid_filtered=${fold_grid_summary}/${grid_type}_pct_5_filtered.grd
  rgn_grd="-R109/158.5/-45/-6"
  inc_grd="-I0.1d/0.1d"
  gmt xyz2grd $rgn_grd $inc_grd $file -G$grid
  gmt grdfilter -D4 -Fg400 $grid -G$grid_filtered
  grid=$grid_filtered
  gmt makecpt -T50/300/26+n -Cpolar -D -I -G-0.667/0.667 > litho.cpt
  gmt makecpt -T50/300/26+n -Cpolar -D -I > litho_contour.cpt
  gmt psbasemap $rgn_map $proj_map -B10 -Bg2 -BWSNE -K -X20c -Y20c > $ps
  gmt grdimage $grid -Clitho.cpt $rgn_map $proj_map -E600 -O -K >> $ps
  gmt grdcontour $grid $rgn_map $proj_map -Clitho_contour.cpt -A- -W0.7p,4_2:2p,+cl -O -K >> $ps
  gmt grdcontour $grid $rgn_map $proj_map -C+170 -W1p,4_2:2p -O -K >> $ps
  gmt pscoast $rgn_map $proj_map -Dh -A50000/0/2 -Wthin,black -O -K >> $ps
  gmt psscale -Dx1.5c/-1.5c+w12c/0.25c+e+h -Clitho.cpt -B50f10 -O -K >> $ps
  rgn_x="-R0/1/0/1"
  proj_x=${proj_map}
  echo "0.5 -0.177 5@+th@+ percentile (km)" | gmt pstext $rgn_x $proj_x -N -O -K >> $ps
  gmt psbasemap $rgn_map $proj_map -BWSNE -O >> $ps
  gmt psconvert -Tj -E600c -A0.1c -P -Z $ps

  f_plot=${fold_plot}/LAB1200_pct_95
  ps=${f_plot}.ps
  jpg=${f_plot}.jpg

  proj_map="-JM15c"
  rgn_map="-R112/155/-44/-10"

  grid_type="LAB1200"
  fold_grid=${fold_data_output}/${grid_type}/distribution
  fold_grid_summary=${fold_grid}/summary
  file=${fold_grid_summary}/${grid_type}_pct_95.xyz
  grid=${fold_grid_summary}/${grid_type}_pct_95.grd
  grid_filtered=${fold_grid_summary}/${grid_type}_pct_95_filtered.grd
  rgn_grd="-R109/158.5/-45/-6"
  inc_grd="-I0.1d/0.1d"
  gmt xyz2grd $rgn_grd $inc_grd $file -G$grid
  gmt grdfilter -D4 -Fg400 $grid -G$grid_filtered
  grid=$grid_filtered
  gmt makecpt -T50/300/26+n -Cpolar -D -I -G-0.667/0.667 > litho.cpt
  gmt makecpt -T50/300/26+n -Cpolar -D -I > litho_contour.cpt
  gmt psbasemap $rgn_map $proj_map -B10 -Bg2 -BWSNE -K -X20c -Y20c > $ps
  gmt grdimage $grid -Clitho.cpt $rgn_map $proj_map -E600 -O -K >> $ps
  gmt grdcontour $grid $rgn_map $proj_map -Clitho_contour.cpt -A- -W0.7p,4_2:2p,+cl -O -K >> $ps
  gmt grdcontour $grid $rgn_map $proj_map -C+170 -W1p,4_2:2p -O -K >> $ps
  gmt pscoast $rgn_map $proj_map -Dh -A50000/0/2 -Wthin,black -O -K >> $ps
  gmt psscale -Dx1.5c/-1.5c+w12c/0.25c+e+h -Clitho.cpt -B50f10 -O -K >> $ps
  rgn_x="-R0/1/0/1"
  proj_x=${proj_map}
  echo "0.5 -0.177 95@+th@+ percentile (km)" | gmt pstext $rgn_x $proj_x -N -O -K >> $ps
  gmt psbasemap $rgn_map $proj_map -BWSNE -O >> $ps
  gmt psconvert -Tj -E600c -A0.1c -P -Z $ps

}

vsmodel="FR12"

fold_data_input=$(awk '$1 ~ /^data_input/' config.ini | awk '{print $3}')
input_locs=$(awk '$1 ~ /^input_locs/' config.ini | awk '{print $3}')
fold_data_output=$(awk '$1 ~ /^data_output/' config.ini | awk '{print $3}')
fold_plot_output=$(awk '$1 ~ /^plot_output/' config.ini | awk '{print $3}')
fold_date=$(awk '$1 ~ /^date/' config.ini | awk '{print $3}')
potential_temperature=$(awk '$1 ~ /^potential_temperature/' config.ini | awk '{print $3}')
solidus_50km=$(awk '$1 ~ /^solidus_50km/' config.ini | awk '{print $3}')
fold_data_output=${fold_data_output}/${fold_date}

plot_LAB_median_MAD_panel
plot_LAB_summary

rm -f gmt.* input.dat output.dat geoth.out lacdevs.dat *.cpt
