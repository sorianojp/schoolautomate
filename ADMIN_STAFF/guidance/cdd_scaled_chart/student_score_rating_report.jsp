<%@ page language="java" import="utility.*,enrollment.ScaledScoreConversion,java.util.Vector " %>
<%
	WebInterface WI   = new WebInterface(request);
	

%>


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>

<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.nav {
     /**color: #000000;**/
	 font-weight:normal;
}
.nav-highlight {
     /**color: #0000FF;**/
     background-color:#BCDEDB;
}

</style>
<%
response.setHeader("Pragma","No-Cache");
response.setDateHeader("Expires",0);
response.setHeader("Cache-Control","no-Cache"); //HTTP 1.0
response.setHeader("Cache-Control","no-store"); //HTTP 1.1
%>

</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="javascript" src="../../../Ajax/ajax.js"></script>
<script language="javascript" src="../../../Ajax/ajax2.js"></script>


<link href="../../../css/jquery.jqplot.min.css" rel="stylesheet" />
<script language="javascript" type="text/javascript" src="../../../jscript/piechart/jquery-1.4.4.min.js"></script>
<script language="javascript" type="text/javascript" src="../../../jscript/piechart/jquery.jqplot.min.js"></script>
<script language="javascript" type="text/javascript" src="../../../jscript/piechart/jqplot.pieRenderer.min.js"></script>


<script language="JavaScript">

function Search(){
	document.form_.test_name.value = document.form_.exam_main_index[document.form_.exam_main_index.selectedIndex].text;	
	var strTemp = document.form_.rating_main_index[document.form_.rating_main_index.selectedIndex].text;
	if(strTemp == 'All')
		strTemp = '';
	document.form_.exam_name.value = strTemp;		
	document.form_.search_.value = '1';
	document.form_.submit();
}

function navRollOver(obj, state) {
  document.getElementById(obj).className = (state == 'on') ? 'nav-highlight' : 'nav';
}

function ViewStudent(strRangeFrom, strRangeTo, strAction){
    var pgLoc = "./print_student_score_rating_report.jsp?test_name="+document.form_.exam_main_index[document.form_.exam_main_index.selectedIndex].text+
		"&exam_name="+document.form_.rating_main_index[document.form_.rating_main_index.selectedIndex].text+
		"&range_from="+strRangeFrom+"&range_to="+strRangeTo+
		"&exam_main_index="+document.form_.exam_main_index.value+
		"&rating_main_index="+document.form_.rating_main_index.value+
		"&sy_from="+document.form_.sy_from.value+
		"&sy_to="+document.form_.sy_to.value+
		"&offering_sem="+document.form_.offering_sem.value+
		"&college_index="+document.form_.college_index.value+
		"&course_index="+document.form_.course_index.value+
		"&major_index="+document.form_.major_index.value+
		"&iAction="+strAction;
	var win=window.open(pgLoc,"PrintWindow",'width=900,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}



</script>


<body>

<%
	DBOperation dbOP  = null;
	String strErrMsg  = null;	
	String strTemp    = null;
	String strTemp2   = null;
	String strTemp3   = null;
	
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-GRADES-IQ Score Rating","student_score_rating_report.jsp");
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
									"Guidance & Counseling","IQ Test",request.getRemoteAddr(), null);

if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.

ScaledScoreConversion scoreConversion = new ScaledScoreConversion();
Vector vRetResult = new Vector();

if(WI.fillTextValue("search_").length() > 0){
	vRetResult = scoreConversion.getReportRating(dbOP, request, 3);
	if(vRetResult == null)
		strErrMsg = scoreConversion.getErrMsg();
}



%>
<form name="form_" action="./student_score_rating_report.jsp" method="post">
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">

    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>::::
          STUDENT SCORE RATING REPORT ::::</strong></font></div></td>
    </tr>
    <tr><td height="25" colspan="6">&nbsp; &nbsp; &nbsp; <strong><font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td></tr>
</table>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
	<tr>
		<td height="25" width="3%">&nbsp;</td>
		<td width="15%">SY/Term: </td>
		
		<td colspan="3">			
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_from"), (String)request.getSession(false).getAttribute("cur_sch_yr_from"));
			%>
			<input name="sy_from" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				onKeyUp='DisplaySYTo("form_","sy_from","sy_to")'>
			-
			<%
				strTemp = WI.getStrValue(WI.fillTextValue("sy_to"), (String)request.getSession(false).getAttribute("cur_sch_yr_to"));
			%>
			<input name="sy_to" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>" 
				onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
				onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
				readonly="yes">
				
				
				
			<%
			strTemp = WI.getStrValue(WI.fillTextValue("offering_sem"), (String)request.getSession(false).getAttribute("cur_sem"));
			%>
			<select name="offering_sem">
			<%if(strTemp.equals("1")){%>
				<option value="1" selected>1st Sem</option>
			<%}else{%>
				<option value="1">1st Sem</option>
			
			<%}if(strTemp.equals("2")){%>
				<option value="2" selected>2nd Sem</option>
			<%}else{%>
				<option value="2">2nd Sem</option>
				
			<%}if(strTemp.equals("3")){%>
				<option value="3" selected>3rd Sem</option>
			<%}else{%>
				<option value="3">3rd Sem</option>
			
			<%}if(strTemp.equals("0")){%>
				<option value="0" selected>Summer</option>
			<%}else{%>
				<option value="0">Summer</option>
			<%}%>
			</select>	  </td>
	</tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>College</td>
		<td colspan="3"> 
		<select name="college_index" onChange="document.form_.submit();">
		<option value="">All</option>
		<%=dbOP.loadCombo("c_index","c_name, c_code", " from college where is_del = 0 order by c_name ", WI.fillTextValue("college_index"), false)%> 
		</select>		</td>
	</tr>
	
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Course</td>
		<%
		strTemp = WI.fillTextValue("college_index");
		
		if(strTemp.length() > 0)
			strTemp = " where is_valid = 1 and is_offered = 1 and c_index = "+strTemp+" order by course_name ";
		else
			strTemp = " where is_valid = 1 and is_offered = 1 order by course_name ";
		
		%>
		<td colspan="3"> 
		<select name="course_index" onChange="document.form_.submit();">
		<option value="">All</option>
		<%=dbOP.loadCombo("course_index","course_name, course_code", " from course_offered "+strTemp , WI.fillTextValue("course_index"), false)%> 
		</select>		</td>
	</tr>
	<tr>
	   <td height="25">&nbsp;</td>
	   <td>Major</td>
	   <td colspan="3">
		<select name="major_index">
		<option value="">All</option>
		<%
strTemp = WI.fillTextValue("course_index");
if(strTemp.compareTo("0") != 0 && strTemp.length() > 0)
{
strTemp = " from major where is_del=0 and course_index="+strTemp ;
%>
          <%=dbOP.loadCombo("major_index","major_name",strTemp, request.getParameter("major_index"), false)%> 
          <%}%>
		</select>
		</td>
	   </tr>
	
	<tr>
		<td height="25">&nbsp;</td>
		<td>Test Name</td>
		<%
		strTemp = WI.fillTextValue("exam_main_index");
		%>
		<td>
			<select name="exam_main_index" onChange="document.form_.submit();">
			<option value="">All</option>
			<%=dbOP.loadCombo("exam_main_index","exam_name", " from CDD_EXAM_MAIN where is_valid = 1", strTemp, false)%> 
			</select>		</td>
	</tr>
	<%if(WI.fillTextValue("exam_main_index").length() > 0){%>
	<tr>
		<td height="25">&nbsp;</td>
		<td>Exam Name</td>
		<td>
			<select name="rating_main_index">
			<%if(WI.fillTextValue("exam_main_index").equals("1")){%>
			<option value="">All</option>
			<%}else if(WI.fillTextValue("exam_main_index").equals("2")){%>
				<option value="">All</option>
				<%=dbOP.loadCombo("rating_main_index","iq_exam_name", " from CDD_IQ_RATING_EXAM_NAME where is_valid = 1", WI.fillTextValue("rating_main_index"), false)%> 
			<%}%>
			</select>		</td>
	</tr>
	<%}%>
	<tr><td colspan="3">&nbsp;</td></tr>
	<tr>
		<td colspan="2" height="25">&nbsp;</td>
		<td><a href="javascript:Search();"><img src="../../../images/form_proceed.gif" border="0"></a>		</td>
	</tr>
</table>


<%
String[] astrConvertSem = {"Summer", "1st Sem", "2nd Sem", "3rd Sem", "4th Sem", "5th Sem", "6th Sem"};
if(vRetResult != null && vRetResult.size() > 0){%>

<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
<tr><td height="25" width="60%">
	<strong><font size="2"><%=WI.fillTextValue("test_name")%><%=WI.getStrValue(WI.fillTextValue("exam_name")," - ","","")%></font></strong></td>
	<td align="right" rowspan="2"><a href="javascript:ViewStudent('','','2');"><img src="../../../images/view.gif" border="0"></a>
	<font size="1">Click to view all student</font>
	</td>
</tr>
<tr><td colspan="4" height="25">
	<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("offering_sem"))]%>
	S.Y. <%=WI.fillTextValue("sy_from")%>-<%=WI.fillTextValue("sy_to")%>
</td></tr>
</table>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
<tr bgcolor="#CCCCCC">
	<td height="25" class="thinborder" width="50%"><strong>REMARK</strong></td>
	<td class="thinborder" width="25%"><strong>TOTAL</strong></td>
	<td class="thinborder" width="25%"><strong>PERCENTAGE</strong></td>
</tr>

<%
strTemp = null;
int iCount = 1;
for(int i = 0; i < vRetResult.size(); i+=5, iCount++){
	if(strTemp == null)
		strTemp = (String)vRetResult.elementAt(i)+","+(String)vRetResult.elementAt(i+2);
	else
		strTemp += ","+(String)vRetResult.elementAt(i)+","+(String)vRetResult.elementAt(i+2);
%>
<tr onClick="ViewStudent('<%=(String)vRetResult.elementAt(i+3)%>','<%=(String)vRetResult.elementAt(i+4)%>','1');" 
	class="nav" id="msg<%=i%>" onMouseOver="navRollOver('msg<%=i%>', 'on')" onMouseOut="navRollOver('msg<%=i%>', 'off');">
	
	<td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>	
	<td class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>	
	<td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"","%","")%></td>
	
	<input type="hidden" name="remark_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i)%>" >
	<input type="hidden" name="total_count_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+1)%>" >
	<input type="hidden" name="percent_<%=iCount%>" value="<%=(String)vRetResult.elementAt(i+2)%>" >
</tr>
<%}%>
<input type="hidden" name="item_count" value="<%=iCount%>" />

</table>

<%}%>

  
 


  
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr><td colspan="8" height="25" align="center" >&nbsp;<div id="chart1" style="margin-top:20px; margin-left:0px; position:absolute"></div><!--<div id="chart_div" style="width:100%; height:100%; float:right"></div>--></td></tr>
</table>
<%if(WI.fillTextValue("search_").length() > 0){%>
<script language="javascript" type="text/javascript">
	var maxDisp = "";
	if(window.onload ) {
    	//do nothing
	}else{
		maxDisp = document.form_.item_count.value;
	}
	
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
<%}%>

<input type="hidden" name="search_" value="<%=WI.fillTextValue("search_")%>" />
<input type="hidden" name="test_name" value="<%=WI.fillTextValue("test_name")%>" />
<input type="hidden" name="exam_name" value="<%=WI.fillTextValue("exam_name")%>" />	
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
