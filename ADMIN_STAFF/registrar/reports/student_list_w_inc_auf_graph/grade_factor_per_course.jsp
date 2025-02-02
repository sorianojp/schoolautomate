
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
<!--<script language="javascript" type="text/javascript" src="../../../../jscript/piechart/jqplot.pieRenderer.js"></script>-->
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


Vector vRetResult = (Vector)request.getSession(false).getAttribute("vGFCourseOverTotColCourse");

Vector vTemp = new Vector();


/*vTemp.addElement("BSMT");
vTemp.addElement("52");
vTemp.addElement("BSOT");
vTemp.addElement("1");
vTemp.addElement("BSPT");
vTemp.addElement("6");
vTemp.addElement("PHARM");
vTemp.addElement("13");

vRetResult = new Vector();

vRetResult.addElement("CAMP");
vRetResult.addElement(vTemp);*/

if(vRetResult == null || vRetResult.size() == 0){%>
<div style="text-align:center; color:#FF0000; font-size:14px; font-weight:bold;">NO RESULT FOUND</div>
<%	return;}

/*
CBA, [BSBA, 18, BSHRM, 3, BSTM, 6, BSMA, 3], 
CON, [BSN, 27], 
CCS, [BSIT, 18, BSCS, 2], 
CCJE, [BSCRM, 22], 
CE, [BSCE, 7, BSCOE, 2, BS ECE, 6], 
CAMP, [BSPT, 16, BSMT, 39, PHARM, 12, BSRT, 2, BSOT, 1], 
CED, [BSEd, 3, BEEd, 2], 
CAS, [AB Com, 6, BSPSY, 6, BSBIO, 1]*/


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

//int iTotal = Integer.parseInt((String)vRetResult.elementAt(0));
int iTotal = 0;

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

int iCount = 1;
int iIndexOf = 0;
strTemp = "select C_CODE, C_NAME from COLLEGE where IS_DEL = 0 order by C_CODE";
java.sql.ResultSet rs = dbOP.executeQuery(strTemp);


vTemp = new Vector();
while(rs.next()){
	iIndexOf = vRetResult.indexOf(rs.getString(1));
	if(iIndexOf == -1)
		continue;
		
	vTemp.addElement(rs.getString(2));
	vTemp.addElement(vRetResult.elementAt(iIndexOf + 1));
}rs.close();

if(vTemp.size() > 0)
	vRetResult = vTemp;	
	
Vector vTemp2  = new Vector();
strTemp = "select course_code from COURSE_OFFERED "+
	" join COLLEGE on (COLLEGE.C_INDEX = COURSE_OFFERED.C_INDEX) "+
	" where IS_VALID = 1 and C_NAME = ? order by course_code";
java.sql.PreparedStatement pstmtCourseCode  = dbOP.getPreparedStatement(strTemp);
for(int i =0 ; i < vRetResult.size(); i +=2){
	vTemp = (Vector)vRetResult.elementAt(i+1);
	pstmtCourseCode.setString(1, (String)vRetResult.elementAt(i));
	rs = pstmtCourseCode.executeQuery();
	vTemp2 = new Vector();
	iTotal = 0;
	while(rs.next()){
		iIndexOf = vTemp.indexOf(rs.getString(1));
		if(iIndexOf == -1)
			continue;
		iTotal += Integer.parseInt(WI.getStrValue(vTemp.elementAt(iIndexOf + 1),"0"));
		vTemp2.addElement(rs.getString(1));
		vTemp2.addElement(vTemp.elementAt(iIndexOf + 1));
	}rs.close();
	vTemp2.insertElementAt(Integer.toString(iTotal),0);
	vRetResult.setElementAt(vTemp2, i + 1);
}

vTemp = vRetResult;
vRetResult = new Vector();
enrollment.ReportRegistrarExtn RR = new enrollment.ReportRegistrarExtn();
//enrollment.ReportRegistrarAUF RR = new enrollment.ReportRegistrarAUF();

//int iTotPopulation = RR.getTotalPopulation(dbOP, strSYFrom, strSemester, null);
int iTotPopulation = 0;
String strPassFailCon = null;


strTemp = "select c_index from college where c_name = ?";
java.sql.PreparedStatement pstmtGetCIndex  = dbOP.getPreparedStatement(strTemp);

%>
<form action="grade_factor_per_course.jsp" method="post" name="form_">
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr>
      <td height="25" align="center" bgcolor="#A49A6A" style="font-weight:bold; color:#FFFFFF">:::: STUDENT WITH <%=WI.getStrValue(strRemarkIndex).toUpperCase()%> 
	  GRADE REPORT PER COURSE ::::</td>
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
String strSchName = SchoolInformation.getSchoolName(dbOP,true,false);
String strSchAddr = SchoolInformation.getAddressLine1(dbOP,false,false);
String strCCode = null;
String strCIndex = null;
int iCollegeCount = 0;
while(vTemp.size() > 0){
	++iCollegeCount;
	strCIndex = null;
	strCCode = (String)vTemp.remove(0);
	vRetResult = (Vector)vTemp.remove(0);
	iTotal = Integer.parseInt(WI.getStrValue(vRetResult.remove(0),"0"));
	
	pstmtGetCIndex.setString(1, strCCode);
	rs = pstmtGetCIndex.executeQuery();
	if(rs.next())
		strCIndex = rs.getString(1);
	rs.close();
	
	iTotPopulation = RR.getTotalPopulation(dbOP, strSYFrom, strSemester, strCIndex);
	
%> 
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
	<tr>
		<td align="center"><b><%=strSchName%></b><br>
		<font size="1"><%=WI.getStrValue(strSchAddr,"","<br>","")%></font>		
		<br><br>
		<strong>STUDENT WITH <%=WI.getStrValue(strRemarkIndex).toUpperCase()%> GRADES PER COURSE</strong>
		<br><strong><%=WI.getStrValue(strCCode).toUpperCase()%><br></strong>	  </td>
	</tr>
  </table>

<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="50%" valign="top">
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
	<tr style="font-weight:bold">
		<td width="24%" height="18" class="">&nbsp;</td>
		<td width="17%" class="" align="center"><font style="font-size:9px;">With <%=strRemarkIndex%> Grades</font></td>
	    <td width="45%" class="" align="center"><font style="font-size:9px;">Total No. of students <br>
	        with <%=strRemarkIndex%> grades in college</font></td>
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
			<input type="hidden" name="percent_<%=iCollegeCount%>_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+1)%>" >
			<input type="hidden" name="remark_<%=iCollegeCount%>_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" >
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
				<div id="chart1_<%=iCollegeCount%>" style=" width:500px; height:360px; display:block;"></div>
			</div>
			
			
		</td>
	</tr>
	<tr><td>&nbsp;</td></tr>
</table> 



<script language="javascript" type="text/javascript">
		var maxDisp_<%=iCollegeCount%> = <%=iCount%>;			
		
		var strValue_<%=iCollegeCount%> = "";
		var strData_<%=iCollegeCount%> = "";	
		var astrData2_<%=iCollegeCount%> = new Array();
		var x_<%=iCollegeCount%> = 0;			
		for(var i = 1; i < maxDisp_<%=iCollegeCount%>; ++i){
			strTemp_<%=iCollegeCount%> = eval('document.form_.remark_<%=iCollegeCount%>_'+i+'.value');		
			strValue_<%=iCollegeCount%> = eval('document.form_.percent_<%=iCollegeCount%>_'+i+'.value');	
			//alert(eval(strValue_<%=iCollegeCount%>));	
			astrData2_<%=iCollegeCount%>[x_<%=iCollegeCount%>++] = new Array(strTemp_<%=iCollegeCount%>,eval(strValue_<%=iCollegeCount%>));					
		}
		
		jQuery.jqplot.config.enablePlugins = true;	
		plot1 = jQuery.jqplot('chart1_<%=iCollegeCount%>', [astrData2_<%=iCollegeCount%>], 
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
<%
if(iTotPopulation == 0)
 	continue;
%>
  
<div style="page-break-after:always;">&nbsp;</div>  

<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">	
<tr>
		<td align="center"><b><%=strSchName%></b><br>
		<font size="1"><%=WI.getStrValue(strSchAddr,"","<br>","")%></font>		
		<br><br>
		<strong>STUDENT WITH <%=WI.getStrValue(strRemarkIndex).toUpperCase()%> GRADES PER COURSE</strong>
		<br><%=WI.getStrValue(strCCode)%>	  </td>
	</tr>
</table>
 <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
 	<tr style="font-weight:bold">
		<td width="14%">&nbsp;</td>
		<td align="center" width="29%" ><font style="font-size:9px;">With <%=WI.getStrValue(strRemarkIndex).toUpperCase()%> Grades</font></td>
		<td align="center" width="37%"><font style="font-size:9px;">Total Population of the College</font></td>		
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
		<input type="hidden" name="total_percent_<%=iCollegeCount%>_<%=iCount%>" value="<%=strTemp%>" >
		<input type="hidden" name="total_remark_<%=iCollegeCount%>_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" >		
	</tr>
	
	<%}%>	
	<tr>
		<td height="25" colspan="4" align="center">		
		<%
		if((iCount * 50) < 300)
			strTemp = "300";
		else			
			strTemp = Integer.toString(iCount * 50);
		%>
		<div id="chart2_<%=iCollegeCount%>" style=" width:<%=strTemp%>px; display:block;"></div>
		</td>
	</tr>
 </table>
 
 
 
 <script language="javascript" type="text/javascript">
	var maxDisp = <%=iCount%>;			
	
	var strValue_<%=iCollegeCount%> = "";
	var strData_<%=iCollegeCount%> = "";		
	var x_<%=iCollegeCount%> = 0;
	var yAxis_<%=iCollegeCount%> = new Array();
	var xAxis_<%=iCollegeCount%> = new Array();
	var iMax_<%=iCollegeCount%> = -1;
	for(var i = 1; i < maxDisp_<%=iCollegeCount%>; ++i){
		strTemp_<%=iCollegeCount%> = eval('document.form_.total_remark_<%=iCollegeCount%>_'+i+'.value');		
		strValue_<%=iCollegeCount%> = eval('document.form_.total_percent_<%=iCollegeCount%>_'+i+'.value');
		xAxis_<%=iCollegeCount%>[x_<%=iCollegeCount%>]	= strTemp_<%=iCollegeCount%>;		
		yAxis_<%=iCollegeCount%>[x_<%=iCollegeCount%>++] = strValue_<%=iCollegeCount%>;		
		if( parseInt(iMax_<%=iCollegeCount%>) < parseInt(strValue_<%=iCollegeCount%>) )				
			iMax_<%=iCollegeCount%> = strValue_<%=iCollegeCount%>;		
	}	
	iMax_<%=iCollegeCount%> = parseInt(iMax_<%=iCollegeCount%>)+2;			
	jQuery.jqplot.config.enablePlugins = true;				
	plot1 = jQuery.jqplot('chart2_<%=iCollegeCount%>', [yAxis_<%=iCollegeCount%>], 
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
					ticks: xAxis_<%=iCollegeCount%>
				},
				yaxis: {
					//renderer: jQuery.jqplot.CategoryAxisRenderer,
					min:0, max:iMax_<%=iCollegeCount%>, numberTicks:x_<%=iCollegeCount%>
				},
			},
			
			highlighter: { show: false }
		}
	);
	
</script>
<%if(vTemp.size() > 0){%>
<div style="page-break-after:always;">&nbsp;</div>
<%}}%>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
  