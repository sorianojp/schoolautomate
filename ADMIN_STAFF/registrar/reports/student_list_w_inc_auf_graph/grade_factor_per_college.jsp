
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../../css/jquery.jqplot.min.css" rel="stylesheet" />

<script language="javascript" type="text/javascript" src="../../../../jscript/piechart/jquery-1.4.4.min.js"></script>
<script language="javascript" type="text/javascript" src="../../../../jscript/piechart/jquery.jqplot.min.js"></script>
<script language="javascript" type="text/javascript" src="../../../../jscript/piechart/jqplot.pieRenderer.min.js"></script>
<script language="javascript" type="text/javascript" src="../../../../jscript/piechart/jqplot.barRenderer.min.js"></script>


<script language="javascript" type="text/javascript" src="../../../../jscript/piechart/jqplot.categoryAxisRenderer.min.js"></script>
<script language="javascript" type="text/javascript" src="../../../../jscript/piechart/jqplot.pointLabels.min.js"></script>

<script language="JavaScript" src="../../../../jscript/common.js"></script>
</head>


<script language="JavaScript">

function PrintPg() {
	if(!confirm("Click OK to print this page"))
		return;

	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	window.print();
}
</script>
<body>
<%@ page language="java" import="utility.*,java.util.Vector" %>

<%


Vector vRetResult = (Vector)request.getSession(false).getAttribute("vGFColOverTotCol");
if(vRetResult == null || vRetResult.size() == 0){%>
<div style="text-align:center; color:#FF0000; font-size:14px; font-weight:bold;">NO RESULT FOUND</div>
<%	return;}

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strTemp = null;
	String strErrMsg = null;
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-Reports - Student Per Grades Status","grade_factor_per_college.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Registrar Management","Reports - Student Per Grades Status",request.getRemoteAddr(),
														"grade_factor_per_college.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../../commfile/unauthorized_page.jsp");
	return;
}

int iTotal = Integer.parseInt((String)vRetResult.elementAt(0));


String strSYFrom = WI.fillTextValue("sy_from");
if(strSYFrom.length() == 0)
	strSYFrom = (String)request.getSession(false).getAttribute("cur_sch_yr_from");	  
String strSemester = WI.fillTextValue("semester");
if(strSemester.length() == 0)
	strSemester = (String)request.getSession(false).getAttribute("cur_sem");	  


//end of authenticaion code.
String strRemarkIndex = WI.fillTextValue("remark_index");
strTemp = "select REMARK from REMARK_STATUS where REMARK_INDEX = "+strRemarkIndex;
strRemarkIndex = dbOP.getResultOfAQuery(strTemp, 0);
Vector vTemp = new Vector();
int iCount = 1;
int iIndexOf = 0;
strTemp = "select C_CODE from COLLEGE where IS_DEL = 0 order by C_CODE";
java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
while(rs.next()){
	iIndexOf = vRetResult.indexOf(rs.getString(1));
	if(iIndexOf == -1)
		continue;
		
	vTemp.addElement(rs.getString(1));
	vTemp.addElement(vRetResult.elementAt(iIndexOf + 1));
}rs.close();
if(vTemp.size() > 0)
	vRetResult = vTemp;


enrollment.ReportRegistrarExtn RR = new enrollment.ReportRegistrarExtn();
//enrollment.ReportRegistrarAUF RR = new enrollment.ReportRegistrarAUF();

int iTotPopulation = RR.getTotalPopulation(dbOP, strSYFrom, strSemester);
//int iTotPopulation = 7349;
String strPassFailCon = null;
%>
<form action="grade_factor_per_college.jsp" method="post" name="form_">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr>
      <td height="25" align="center" bgcolor="#A49A6A" style="font-weight:bold; color:#FFFFFF">:::: STUDENT WITH <%=WI.getStrValue(strRemarkIndex).toUpperCase()%> 
	  GRADE REPORT PER COLLEGE ::::</td>
    </tr>   
	<tr>
	    <td align="right">
		<a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a>
		<font size="1">Click to print report</font>
		</td>
	    </tr>
  </table>
<%
String[] astrConvertTerm = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER","FOURTH SEMESTER"};
%> 
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
	
	<tr>
		<td align="center"><b><%=SchoolInformation.getSchoolName(dbOP,true,false)%></b><br>
		<font size="1"><%=WI.getStrValue(SchoolInformation.getAddressLine1(dbOP,false,false),"","<br>","")%></font>		
		<br><br>
		<strong>STUDENT WITH <%=WI.getStrValue(strRemarkIndex).toUpperCase()%> GRADES PER COLLEGE</strong>
		<br>&nbsp;	  </td>
	</tr>
  </table>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="50%" valign="top">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr style="font-weight:bold">
		<td width="24%" height="18" class="">&nbsp;</td>
		<td width="17%" class="" align="center"><font style="font-size:9px;">With <%=strRemarkIndex%> Grades</font></td>
	    <td width="45%" class="" align="center"><font style="font-size:9px;">Total No. of students in the Univ. <br>
	        with <%=strRemarkIndex%> grades(colleges only)</font></td>
	    <td width="14%" class="" align="center"><font style="font-size:9px;">Percentage</font></td>
	</tr>
	<%
	iCount = 1;	
	for(int i =0; i < vRetResult.size(); i += 2,iCount++) {%>
		<tr>
			
		
			<td height="18" class="thinborderNONE">&nbsp;<%=vRetResult.elementAt(i)%></td>
			<td class="thinborderNONE" align="center"><%=vRetResult.elementAt(i + 1)%></td>
		    <td class="thinborderNONE" align="center"><%=iTotal%></td>
			<%
			strTemp = RR.getPercentage((String)vRetResult.elementAt(i + 1), Integer.toString(iTotal));
			strTemp = CommonUtil.formatFloat(Double.parseDouble(strTemp),3);
			
			
			if( strTemp.indexOf(".") > -1 ){
				strErrMsg = strTemp.substring(strTemp.indexOf(".")+1);
				if(Double.parseDouble(strErrMsg) >= 500)
					strTemp = Integer.toString( (int)Math.ceil(Double.parseDouble(strTemp)) );
				else
					strTemp = Integer.toString( (int)Math.rint(Double.parseDouble(strTemp)) );
			}else
				strTemp = Integer.toString( (int)Math.rint(Double.parseDouble(strTemp)) );
			
			
			%>
		    <td class="thinborderNONE" align="center"><%=strTemp%></td>
			<input type="hidden" name="percent_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+1)%>" >
			<input type="hidden" name="remark_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" >
		</tr>
		
		
		
	<%}%>
		<tr style="font-weight:bold">
		  <td height="18" class="thinborderNONE" align="right"></td>
		  <td class="thinborderNONE" align="center"><strong><%=iTotal%></strong></td>
          <td class="thinborderNONE">&nbsp;</td>
          <td class="thinborderNONE">&nbsp;</td>
		</tr>
</table>
		</td>
		
		<td width="50%" valign="top" align="left">
			<div style="display:block;">
				<!--<div id="chart1" style="margin-top:20px; margin-right:200px; position:absolute;"></div>-->
				<div id="chart1" style=" width:300px; display:block;"></div>
			</div>
			
			
		</td>
	</tr>
	<tr><td>&nbsp;</td></tr>
</table> 



<script language="javascript" type="text/javascript">
		var maxDisp = <%=iCount%>;			
		
		var strValue = "";
		var strData = "";	
		var astrData2 = new Array();
		var x = 0;			
		for(var i = 1; i < maxDisp; ++i){
			strTemp = eval('document.form_.remark_'+i+'.value');		
			strValue = eval('document.form_.percent_'+i+'.value');		
			astrData2[x++] = new Array(strTemp,eval(strValue));					
		}
		
		jQuery.jqplot.config.enablePlugins = true;	
		plot1 = jQuery.jqplot('chart1', [astrData2], 
			{
				title: 'Percentage', 
				seriesDefaults: {renderer: jQuery.jqplot.PieRenderer, rendererOptions: { sliceMargin:0,  showDataLabels: true } }, 
				legend: { show:true },
				grid: {
					drawBorder: false, 
					drawGridlines: false,
					background: '#ffffff',
					shadow:false
				}
			}
		);
</script>
  
  
<div style="page-break-after:always;">&nbsp;</div>  

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
<tr>
	<td align="center"><b><%=SchoolInformation.getSchoolName(dbOP,true,false)%></b><br>
	<font size="1"><%=WI.getStrValue(SchoolInformation.getAddressLine1(dbOP,false,false),"","<br>","")%></font>		
	<br><br>
	<strong>STUDENT WITH <%=WI.getStrValue(strRemarkIndex).toUpperCase()%> GRADES PER COLLEGE</strong>
	<br>&nbsp;	  </td>
</tr>
</table>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
 	<tr style="font-weight:bold">
		<td width="14%">&nbsp;</td>
		<td align="center" width="29%" ><font style="font-size:9px;">With <%=strRemarkIndex%> Grades</font></td>
		<td align="center" width="37%"><font style="font-size:9px;">Total Population(Colleges only)</font></td>		
		<td align="center" width="20%"><font style="font-size:9px;">Percentage</font></td>
	</tr>
	
	<%
	iCount = 1;	
	for(int i =0; i < vRetResult.size(); i += 2,iCount++) {%>
	<tr>
		<td><%=vRetResult.elementAt(i)%></td>
		<td align="center"><%=vRetResult.elementAt(i + 1)%></td>
		<td align="center"><%=iTotPopulation%></td>
		<%
		strTemp = RR.getPercentage((String)vRetResult.elementAt(i + 1), Integer.toString(iTotPopulation));
		strTemp = CommonUtil.formatFloat(Double.parseDouble(strTemp),3);
		
		
		/*if( strTemp.indexOf(".") > -1 ){
			strErrMsg = strTemp.substring(strTemp.indexOf(".")+1);
			if(Double.parseDouble(strErrMsg) >= 5)
				strTemp = Integer.toString( (int)Math.ceil(Double.parseDouble(strTemp)) );
			else
				strTemp = Integer.toString( (int)Math.rint(Double.parseDouble(strTemp)) );
		}else
			strTemp = Integer.toString( (int)Math.rint(Double.parseDouble(strTemp)) );*/
		
		
		%>
		<td class="thinborderNONE" align="center"><%=strTemp%></td>
		<input type="hidden" name="total_percent_<%=iCount%>" value="<%=strTemp%>" >
		<input type="hidden" name="total_remark_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" >		
	</tr>
	
	<%}%>	
	<tr>
		<%
		if((iCount * 50) < 300)
			strTemp = "300";
		else			
			strTemp = Integer.toString(iCount * 50);
		%>
		<td height="25" colspan="4" align="center">
		<div id="chart2" style=" width:<%=strTemp%>px; display:block;"></div>
		</td>
	</tr>
 </table>
 
 
 
 <script language="javascript" type="text/javascript">
	var maxDisp = <%=iCount%>;			
	
	var strValue = "";
	var strData = "";		
	var x = 0;
	var yAxis = new Array();
	var xAxis = new Array();
	var iMax = -1;
	for(var i = 1; i < maxDisp; ++i){
		strTemp = eval('document.form_.total_remark_'+i+'.value');		
		strValue = eval('document.form_.total_percent_'+i+'.value');
		xAxis[x]	= strTemp;		
		yAxis[x++] = strValue;		
		if( parseInt(iMax) < parseInt(strValue) )				
			iMax = strValue;		
	}	
	iMax = parseInt(iMax)+.5;			
	jQuery.jqplot.config.enablePlugins = true;				
	plot1 = jQuery.jqplot('chart2', [yAxis], 
		{
			animate: !jQuery.jqplot.use_excanvas,
			title: 'Percentage', 
			//stackSeries: true,
			seriesDefaults: {
				renderer: jQuery.jqplot.BarRenderer, 						
				pointLabels: {show: true} 
			}, 
			axes: {
				xaxis: {
					renderer: jQuery.jqplot.CategoryAxisRenderer,
					ticks: xAxis
				},
				yaxis: {
					//renderer: jQuery.jqplot.CategoryAxisRenderer,
					min:0, max:iMax, numberTicks:x
				},
			},
			
			highlighter: { show: false }
		}
	);
	
</script>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
  