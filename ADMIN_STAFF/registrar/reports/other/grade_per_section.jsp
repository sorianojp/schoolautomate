<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";
boolean bolIsCGH = strSchCode.startsWith("CGH");//bolIsCGH = true;
boolean bolShowGWAPercent = false;
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../../jscript/td.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	if(document.form_.course_index.selectedIndex >=0)
	{
		document.form_.cn.value = 
				document.form_.course_index[document.form_.course_index.selectedIndex].text;
		<%if(!bolIsCGH){%>
			//document.form_.mn.value = document.form_.major_index[document.form_.major_index.selectedIndex].text;
		<%}%>
	}
	else
	{
		document.form_.cn.value = "";
		document.form_.mn.value = "";
	}
	GradeChanged();
}


function PrintPage() {
	document.bgColor = "#FFFFFF";
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);	

/**
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
	document.getElementById('myADTable2').deleteRow(0);
**/
//	document.getElementById('myADTable3').deleteRow(0);
//	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable3').deleteRow(0);
	document.getElementById('myADTable4').deleteRow(0);
	document.getElementById('myADTable4').deleteRow(0);
	
	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
function GradeChanged() {
	document.form_.grade_name.value = document.form_.grading_period[document.form_.grading_period.selectedIndex].text;
}
</script>
<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,enrollment.GradeSystemExtn,java.util.Vector " %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String[] astrConvertToSem = {"Summer","1st Sem","2nd Sem","3rd Sem","4th Sem"};
	String[] astrConvertToYear = {"","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year"};
	String[] astrYearLevel = {"","First Year", "Second Year", "Third Year", "Fourth Year","Fifth Year", "Sixth Year"};
//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Registrar Management-REPORT-Assign Section","assign_section.jsp");
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
														"Registrar Management","REPORTS",request.getRemoteAddr(),
														"assign_section.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vRetResult = null;
GradeSystemExtn gsE = new GradeSystemExtn();


if(WI.fillTextValue("grading_period").length() > 0 
		&& WI.fillTextValue("section").length() > 0) {
	vRetResult = gsE.getSectionSummarizedRating(dbOP,request);
	
	if (vRetResult == null) 
		strErrMsg = gsE.getErrMsg();
}

%>

<form name="form_" action="./grade_per_section.jsp" method="post" onSubmit="SubmitOnceButton(this);">
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="4" align="center"><font color="#FFFFFF"><strong>:::: 
        ASSIGN SECTION PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td width="2%" height="25" >&nbsp;</td>
      <td height="25" colspan="3" >&nbsp;&nbsp;&nbsp;<strong><%=WI.getStrValue(strErrMsg)%></strong></td>
    </tr>
    <tr> 
      <td height="25" >&nbsp;</td>
      <td >Course </td>
      <td colspan="2" ><select name="course_index" onChange="ReloadPage();">
          <%=dbOP.loadCombo("course_index","course_name",
		  " from course_offered where IS_DEL=0 and is_valid=1 and degree_type=0 and is_offered=1 order by course_name asc",
		  request.getParameter("course_index"), false)%> 
		 </select></td>
    </tr>
    <tr> 
      <td width="2%" height="25" >&nbsp;</td>
      <td width="8%" height="25" >SY/Term </td>
      <td width="41%" >
<%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
if(strTemp == null)
	strTemp = "";
%>
		  <input name="sy_from" type="text" size="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyInteger('form_','sy_from');style.backgroundColor='white'"
	  onKeyUp='AllowOnlyInteger("form_","sy_from");DisplaySYTo("form_","sy_from","sy_to")'>
        to 
<%
strTemp = WI.fillTextValue("sy_to");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
if(strTemp == null)
	strTemp = "";
%>        <input name="sy_to" type="text" size="4" value="<%=strTemp%>" class="textbox"
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
		readonly="yes">
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
<select name="semester" onChange="ReloadPage();document.form_.submit()">
          <option value="1">1st Sem</option>
          <%
strTemp = WI.fillTextValue("semester");
if(strTemp.length() == 0) 
	strTemp = (String)request.getSession(false).getAttribute("cur_sem");
if(strTemp == null)
	strTemp = "";
if(strTemp.compareTo("2") ==0){%>
          <option value="2" selected>2nd Sem</option>
          <%}else{%>
          <option value="2">2nd Sem</option>
          <%}if(strTemp.compareTo("3") ==0){%>
          <option value="3" selected>3rd Sem</option>
          <%}else{%>
          <option value="3">3rd Sem</option>
          <%}if(strTemp.compareTo("0") ==0){%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
      </select></td>
      <td width="49%" >Year  
        <select name="year_level">
          <option value="1">1st</option>
          <%
strTemp = request.getParameter("year_level");
if(strTemp == null) strTemp = "";
if(strTemp.compareTo("2") ==0)
{%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.equals("3"))
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.equals("4"))
{%>
          <option value="4" selected>4th</option>
          <%}else{%>
          <option value="4">4th</option>
          <%}if(strTemp.equals("5"))
{%>
          <option value="5" selected>5th</option>
          <%}else{%>
          <option value="5">5th</option>
          <%}if(strTemp.compareTo("6") ==0)
{%>
          <option value="6" selected>6th</option>
          <%}else{%>
          <option value="6">6th</option>
          <%}%>
        </select></td>
    </tr>
<%if(WI.fillTextValue("sy_from").length() > 0){%>	
    <tr>
      <td height="25" >&nbsp;</td>
      <td colspan="2" >
Section Name :
  <select name="section" onChange="ReloadPage();">
    <%=dbOP.loadCombo("distinct section","section", 
			  	" from e_sub_section where IS_valid=1 and is_lec = 0 and offering_sy_from=" +
			  WI.fillTextValue("sy_from")+" and offering_sem=" + WI.fillTextValue("semester") + 
			  " and exists (select * from curriculum where " +
			  " sub_index = e_sub_section.sub_index and course_index = " + WI.fillTextValue("course_index") + " and is_valid = 1 and year=" + WI.fillTextValue("year_level") +
			  ") order by e_sub_section.section",WI.fillTextValue("section"), false)%>
  </select>  </td>
      <td>Grading Period : 
	<select name="grading_period" onChange="GradeChanged();">
	    <%=dbOP.loadCombo("exam_name","exam_name + ' Grade'", 
			  	" from fa_pmt_schedule where IS_valid=1 and is_del = 0 " + 
				" order by exam_period_order",WI.fillTextValue("grading_period"), false)%>
	</select>	  </td>
    </tr>
<%}%>
    <tr>
      <td height="10" align="center">&nbsp;</td>
      <td height="10" colspan="3">Excluded Subjects : 
      <input name="exclude_subj" type="text" class="textbox" 
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		value="<%=WI.fillTextValue("exclude_subj")%>" size="32" > 
	  <font size="1">separate entries with comma (,) </font></td>
    </tr>
    <tr>
      <td height="10" align="center">&nbsp;</td>
      <td height="10" colspan="3">&nbsp;</td>
    </tr>
    <tr> 
      <td colspan="4" height="10" align="center">
	  	<input type="submit" name="1" value="Show Result" style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="document.form_.show_result.value=1;GradeChanged();">	
    Number of rows per page : <select name="print_pr_pg">
	<%
	int iDef = Integer.parseInt(WI.getStrValue(WI.fillTextValue("print_pr_pg"), "40"));
	for(int i = 0; i < 65; ++i) {
		if(iDef == i) 
			strTemp = " selected";
		else	
			strTemp = "";
		%>
		<option value="<%=i%>" <%=strTemp%>><%=i%></option>
		<%}%>
	</select>
	  </td>
	
	</tr>
    <tr>
      <td colspan="4" height="10" align="center">&nbsp;</td>
    </tr>
  </table>
  <%
boolean bolIsFinal = WI.fillTextValue("grade_name").toLowerCase().startsWith("final");

int iCurRow = 0; int iTotalPage = 0; int iCurPage = 0; double dAverage = 0d; double dSubGrade = 0d; double dTotalUnit = 0d;
if(vRetResult != null && vRetResult.size() > 0){
	Vector vSubCodes = (Vector)vRetResult.elementAt(0);
	int k = 0; int iRowCount = 0;
	int iSubCodes = vSubCodes.size();
	int iSizeOfVec = 0;
/////////////// Find total number of pages /////////////////	
	for(int i = 1; i < vRetResult.size(); i += 5) {
		if(vRetResult.elementAt(i) != null)
			++iSizeOfVec;
	}
	iTotalPage = iSizeOfVec/iDef;
	if(vRetResult.size() % iDef > 0) 
		++iTotalPage;
/////////// end of finding total number of pages. 		
for(int i = 1; i < vRetResult.size(); ) { 
	iCurRow = 0; ++iCurPage;
	
%>

  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0">    
    <tr>
      <td  align="center"><strong>CHINESE GENERAL HOSPITAL COLLEGE OF NURSING</strong></td>
    </tr>
    <tr>
      <td  align="center">
		<strong><%=astrYearLevel[Integer.parseInt(WI.fillTextValue("year_level"))].toUpperCase()%>		</strong>	  </td>
    </tr>
    <tr>
      <td  align="center">
	  <script language="javascript">
	  	document.write("<strong>" + 
					document.form_.grading_period[document.form_.grading_period.selectedIndex].text + 
					"</strong>");
	  </script>	  </td>
    </tr>
    <tr>
      <td align="center"> <strong>School Year :  
	  			<%=WI.fillTextValue("sy_from") + " - " + WI.fillTextValue("sy_to")%></strong>	  </td>
    </tr>
    <tr>
      <td align="right" style="font-size:10px;">Page <%=iCurPage%> of <%=iTotalPage%>&nbsp;&nbsp;</td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder">    
    <tr>
      <td colspan="3" class="thinborder">&nbsp;	 
	  <script language="javascript">
	  	document.write("<strong>" + 
					document.form_.section[document.form_.section.selectedIndex].text + 
					"</strong>");
	  </script></td>
	<% for (k = 0; k < iSubCodes; k += 3) {%> 
      <td class="thinborder" width="5%"><%=(String)vSubCodes.elementAt(k)%></td>
    <%}%> 
	  <td width="5%" align="center" class="thinborder">AVE</td>
    </tr>
<% for (; i < vRetResult.size();) { 
if(iCurRow >= iDef)
	break;
++iCurRow;
%>
    <tr>
      <td width="2%" class="thinborder"><%=++iRowCount%>.</td>
      <td width="11%" height="22" class="thinborder"><%=(String)vRetResult.elementAt(i)%></td>
      <td width="23%" class="thinborder"><%=(String)vRetResult.elementAt(i+1)%></td>
	<% dAverage = 0d;dTotalUnit = 0d;
		vRetResult.setElementAt(null, i);
		vRetResult.setElementAt(null, i+1);
		
	 for (k = 0; k < iSubCodes; k += 3) {
		if ( i < vRetResult.size() && 
			vRetResult.elementAt(i) == null && 
			 (((String)vRetResult.elementAt(i+2)).toLowerCase()).equals(((String)vSubCodes.elementAt(k)).toLowerCase())){
			 strTemp = (String)vRetResult.elementAt(i+3);
			int iIndexOf = strTemp.indexOf(".");
			if(iIndexOf != -1)
				strTemp = strTemp.substring(0, iIndexOf);
			 i += 5;
			 try {
			 	dSubGrade = Double.parseDouble(strTemp);
				dAverage += dSubGrade * Double.parseDouble((String)vSubCodes.elementAt(k + 1));
				dTotalUnit += Double.parseDouble((String)vSubCodes.elementAt(k + 1));
				
			 	if(dSubGrade < 75)
					strTemp = "<font color=red>"+strTemp+"</font>";	
			 }
			 catch(Exception e){
			 	strTemp = "<font color=red>"+strTemp+"</font>";	
			 }
		}else{
			strTemp = "--";
		}
		
		
	%> 
      <td class="thinborder" align="center"><%=strTemp%></td>
	<%}
		if (i < vRetResult.size() && vRetResult.elementAt(i) == null) {
			// infinite loop
			break;
		}
	%>   
      <td class="thinborder" align="center"><%if(bolIsFinal){%><%=CommonUtil.formatFloat(dAverage/dTotalUnit,2)%><%}else{%>&nbsp;<%}%></td>
    </tr>
<%}%> 
  </table>
<%if(iTotalPage != iCurPage){%>
<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}//page break only if it is not last page. 

}//outer For loop to print per page.. %>
  <table bgcolor="#FFFFFF"  width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable3">
    <tr style="font-weight:bold">
      <td  align="center" style="font-size:14px">
	  <a href="javascript:PrintPage()"><img src="../../../../images/print.gif" border="0"></a>
	  
		
      </td>
    </tr>
  </table>
  
  <%
	}//vRetResult is not null
%>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0" id="myADTable4">
    <tr>
      <td colspan="8" height="25">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="8" height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="show_result">
  <input type="hidden" name="cn">
  <input type="hidden" name="grade_name">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
