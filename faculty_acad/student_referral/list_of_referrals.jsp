<%@ page language="java" import="utility.*,osaGuidance.GDStudReferralFollowUp,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
	if (strSchCode == null)
		strSchCode = "";
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript">
function PrintPg() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);//13 rows removed.

	document.getElementById('myADTable2').deleteRow(0);//13 rows removed.

	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.

}
</script>
<body>
<%
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	try	{
		dbOP = new DBOperation();
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
String[] astrSortByName    = {"Lastname","Course","Year Level"};
String[] astrSortByVal     = {"lname","course_name","year_level"};


int iSearchResult = 0;

GDStudReferralFollowUp studReferral = new GDStudReferralFollowUp(request);
if(WI.fillTextValue("search_").compareTo("1") == 0 && request.getSession(false).getAttribute("userIndex") != null){
	request.setAttribute("faculty_index",(String)request.getSession(false).getAttribute("userIndex"));
	vRetResult = studReferral.searchReferral(dbOP);
	if(vRetResult == null)
		strErrMsg = studReferral.getErrMsg();
	else	
		iSearchResult = studReferral.getSearchCount();
}
%>
<form action="./list_of_referrals.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr > 
      <td width="100%" height="25" valign="top"><div align="center">
	  <strong><u>:::: STUDENT REFERRAL - SEARCH/LISTINGS PAGE ::::</u></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4" style="font-size:14px; color:#FF0000; font-weight:bold"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td width="14%">Student ID</td>
      <td width="35%">
	  	<input type="text" name="id_number" value="<%=WI.fillTextValue("id_number")%>" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
      <td width="14%">Urgency Level </td>
      <td width="32%">
	  <select name="urgency_i">
	  <option value="">N/A</option>
        <%=dbOP.loadCombo("URGENCY_INDEX","URGENCY_NAME"," from GD_REFERRAL_URGENCY order by URGENCY_ORDER asc", WI.fillTextValue("urgency_i"), false)%>
      </select></td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td>Lastname</td>
      <td>
	  	<select name="lname_con">
        <%= studReferral.constructGenericDropList(WI.fillTextValue("lname_con"),astrDropListEqual,astrDropListValEqual)%> </select>&nbsp;&nbsp;
	  	<input type="text" name="lname" value="<%=WI.fillTextValue("lname")%>" class="textbox" size="16"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">		</td>
      <td>Action</td>
      <td>
	  <select name="action_i">
	  <option value="">N/A</option>
        <%=dbOP.loadCombo("action_index","action_name"," from GD_REFERRAL_ACTION order by ACTION_NAME asc", WI.fillTextValue("action_i"), false)%>
      </select></td>
    </tr>
    <tr> 
      <td width="5%" height="26">&nbsp;</td>
      <td>Firstname</td>
      <td>
	  	<select name="fname_con">
        <%= studReferral.constructGenericDropList(WI.fillTextValue("fname_con"),astrDropListEqual,astrDropListValEqual)%> </select>&nbsp;&nbsp;
	  	<input type="text" name="fname" value="<%=WI.fillTextValue("fname")%>" class="textbox" size="16"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
      <td>Year Level </td>
      <td><select name="year_level">
        <option value="">N/A</option>
        <%
strTemp = WI.fillTextValue("year_level");
if(strTemp.compareTo("1") ==0)
{%>
        <option value="1" selected>1st</option>
        <%}else{%>
        <option value="1">1st</option>
        <%}if(strTemp.compareTo("2") ==0){%>
        <option value="2" selected>2nd</option>
        <%}else{%>
        <option value="2">2nd</option>
        <%}if(strTemp.compareTo("3") ==0)
{%>
        <option value="3" selected>3rd</option>
        <%}else{%>
        <option value="3">3rd</option>
        <%}if(strTemp.compareTo("4") ==0)
{%>
        <option value="4" selected>4th</option>
        <%}else{%>
        <option value="4">4th</option>
        <%}if(strTemp.compareTo("5") ==0)
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
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">Course </td>
      <td height="26" colspan="3">
		<select name="course_index">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 "+
 										" order by course_name asc", request.getParameter("course_index"), false)%> 
        </select>		</td>
    </tr>
    
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26"><u><strong>Referred by</strong></u></td>
      <td height="26" colspan="3">&nbsp; </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">Employee ID</td>
      <td height="26" colspan="3" valign="bottom">
	  	<input type="text" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
	  </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">Lastname</td>
      <td height="26" colspan="3" valign="bottom">
	  	<select name="lname_con_emp">
        <%= studReferral.constructGenericDropList(WI.fillTextValue("lname_con_emp"),astrDropListEqual,astrDropListValEqual)%> </select>&nbsp;&nbsp;
	  	<input type="text" name="lname_emp" value="<%=WI.fillTextValue("lname_emp")%>" class="textbox" size="16"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">Firstname</td>
      <td height="26" colspan="3" valign="bottom">
	  	<select name="fname_con_emp">
        <%= studReferral.constructGenericDropList(WI.fillTextValue("fname_con_emp"),astrDropListEqual,astrDropListValEqual)%> </select>&nbsp;&nbsp;
	  	<input type="text" name="fname_emp" value="<%=WI.fillTextValue("fname_emp")%>" class="textbox" size="16"
	  	onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">	  </td>
    </tr>
<!--    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26" valign="bottom"><strong><u>SORT</u></strong> </td>
      <td height="26" colspan="3" valign="bottom">&nbsp;</td>
    </tr>
    <tr> 
      <td height="38">&nbsp;</td>
      <td height="38" colspan="4">1) 
        <select name="select5">
          <option>Lastname</option>
          <option>Course </option>
          <option>Year </option>
          <option>Urgency</option>
        </select> <select name="select6">
          <option>Ascending</option>
          <option>Descending</option>
        </select>
        2) 
        <select name="select10">
          <option>Lastname</option>
          <option>Course </option>
          <option>Year </option>
          <option>Urgency</option>
        </select> <select name="select7">
          <option>Ascending</option>
          <option>Descending</option>
        </select> </td>
    </tr>
-->    
    <tr> 
      <td height="28">&nbsp;</td>
      <td>&nbsp;</td>
      <td colspan="3" valign="bottom">
	  <input type="image" src="../../images/form_proceed.gif" border="0" onClick="document.form_.search_.value='1'"> 
      </td>
    </tr>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
    <tr> 
      <td height="26" colspan="5"><div align="right"><font size="1"><a href="javascript:PrintPg();"><img src="../../images/print.gif" border="0"></a>click 
          to PRINT Search Result</font></div></td>
    </tr>
  </table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder" id="myADTable2">
    <tr> 
      <td height="25" colspan="11" class="thinborder"><div align="center"><font color="#0000FF"><strong>:: 
          STUDENT REFERRAL LISTINGS :: </strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="11" class="thinborder" align="right" style="font-size:9px;">Date and time printed : <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;</td>
    </tr>
    <tr> 
      <td width="8%" height="25" align="center" class="thinborder" style="font-size:9px; font-weight:bold">STUDENT ID</td>
      <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">NAME</td>
      <td width="5%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">SY-TERM</td>
      <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">COURSE-YR</td>
      <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">SUBJECT</td>
      <!--      <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">COURSE - YR </td>
-->      <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">REFERRED BY</td>
      <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">REFERRAL DATE</td>
      <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">URGENCY</td>
      <td width="25%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">REASONS FOR REFERRAL</td>
      <td width="10%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">ACTION</td>
<!--
      <td width="17%" align="center" class="thinborder" style="font-size:9px; font-weight:bold">REMARKS</td>
-->
    </tr>
<%for(int i = 0; i < vRetResult.size(); i += 14){%>
    <tr>
      <td height="25" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 1), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 12), "&nbsp;")%> - <%=WI.getStrValue(vRetResult.elementAt(i + 13), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 9), "&nbsp;")%><%=WI.getStrValue((String)vRetResult.elementAt(i + 10), "-", "", "")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 11), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 4), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 2), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 5), "&nbsp;")%></td>
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 6), "&nbsp;")%></td>
<!--
      <td class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 7), "&nbsp;")%></td>
-->
    </tr>
<%}%>

<%}//if vRetResult is not null%>
  </table>

<input type="hidden" name="search_" value="<%=WI.fillTextValue("search_")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>