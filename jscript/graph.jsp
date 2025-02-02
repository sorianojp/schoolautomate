<html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="./css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<body>

<%@ page language="java" import="utility.*" %>
<%
PlotBarGraph plot2DGraph = new PlotBarGraph();
String strXAxisName = "Year Level ---->";
String strYAxisName = "ENROLLEES IN NOS";
int iWidthOfGraph   = 600;
int iHeightOfGraph  = 500;
int iMaxValueYAxis  = 12000;
String[] astrXAxisValues={"2004","2005","2006","2007","2008","2009"};
float[] afYAxisValues   = {2500,7000,9000,10000,2000,3000};
String strBGColor = "#FFE6CC";
String[] astrColumnColor={"#FF00FF","#bFF0b0","#FF0000","#00CCFF","#C9A26D","#98CBCB"};

%>
<%=plot2DGraph.plot2DGraph(strXAxisName, strYAxisName,iWidthOfGraph,iHeightOfGraph,iMaxValueYAxis,astrXAxisValues,afYAxisValues,
								strBGColor,astrColumnColor)%>



This is plotted in HTML without JSP file call. 

<table width="623" height="500" align="center">
<tr>
	<td width="23" height="500" align="right">
		E <br> N <br> R <br> O <br> L <br> L <br> E <br> E <br> S <br> <br>  I  <br> N <br> <br>   N <br> O <br>
      S  </td>
	<td>

	<table width="600" height="500" bgcolor="#FFE6CC">
	  <tr>
		<td valign="bottom">
			<table width="60" height="200">
				<tr>
					<td valign="top" bgcolor="#FF00FF">2,500</td>
				</tr>
			</table>
		</td>
		<td valign="bottom">
			<table width="60" height="300">
				<tr>
					
                <td valign="top" bgcolor="#bFF0b0">7000</td>
				</tr>
			</table>
		</td>
		<td valign="bottom">
			<table width="60" height="400">
				<tr>
					
                <td valign="top" bgcolor="#FF0000">9000</td>
				</tr>
			</table>
		</td>
		<td valign="bottom">
			<table width="60" height="400">
				<tr>
					<td valign="top" bgcolor="#00CCFF">10,000
					</td>
				</tr>
			</table>
		</td>
		<td valign="bottom">
			<table width="60" height="200">
				<tr>
					<td valign="top" bgcolor="#C9A26D">2,000
					</td>
				</tr>
			</table>
		</td>
		<td valign="bottom">
			<table width="60" height="250">
				<tr>
					
                <td valign="top" bgcolor="#98CBCB">3,000 </td>
				</tr>
			</table>
		</td>
	  </tr>
	  </table>
	</td>	
</tr>
 </table>
  
  <table width="623" align="center">
	<td width="23">&nbsp;</td>
    <td height="25">2004</td>
    <td>2005</td>
    <td>2006</td>
    <td>2007</td>
    <td>2008</td>
    <td>2009</td>

  </tr>
</table>
<div align="center">Year Level ----> </div>
</body>
</html>