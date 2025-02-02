<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="javascript">
function PrintPg() {
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	document.getElementById('myADTable1').deleteRow(0);
	
	document.getElementById('myADTable2').deleteRow(0);//13 rows removed.

	alert("Click OK to print this page");
	window.print();//called to remove rows, make bk white and call print.
}
</script>
<body>
<%@ page language="java" import="utility.*,osaGuidance.GDStudReferralFollowUp,java.util.Vector" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
	if (strSchCode == null)
		strSchCode = "";
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	
	boolean bolIsBasic = WI.fillTextValue("is_basic").equals("1");		
	
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
if(WI.fillTextValue("search_").compareTo("1") == 0){
	vRetResult = studReferral.searchFollowUp(dbOP);
	if(vRetResult == null)
		strErrMsg = studReferral.getErrMsg();
	else	
		iSearchResult = studReferral.getSearchCount();
}
%>
<form action="./followup_record.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr > 
      <td width="100%" height="25" valign="top"><div align="center">
<%
String[] astrConvertSemester = {"Summer","1st Sem", "2nd Sem", "3rd Sem"};
if(bolIsBasic)
	astrConvertSemester[1] = "Regular";
	
if(WI.fillTextValue("sy_from").length() > 0) {
	strTemp = " For SY : "+WI.fillTextValue("sy_from")+" - "+WI.fillTextValue("sy_to")+ ", "+
		astrConvertSemester[Integer.parseInt(WI.fillTextValue("semester"))];
}	
else if(request.getParameter("search_") != null)	
	strTemp = " Till date ";  
else	
	strTemp = "";
%>
	  <strong><u>:::: Student Follow up - Listing  - <%=strTemp%> ::::</u></strong></div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" id="myADTable1">
    <tr>
      <td height="26">&nbsp;</td>
      <td colspan="2" style="font-size:14px; color:#FF0000; font-weight:bold"><%=WI.getStrValue(strErrMsg)%></td>
    </tr>
    <tr> 
      <td width="4%" height="26">&nbsp;</td>
      <td width="18%">Follow up for SY/Term </td>
      <td width="78%">
<%
	strTemp = WI.fillTextValue("sy_from");
	if(request.getParameter("search_") == null && strTemp.length() ==0) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp=" DisplaySYTo('form_','sy_from','sy_to')">
<%
	strTemp = WI.fillTextValue("sy_to");
	if(request.getParameter("search_") == null && strTemp.length() ==0) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
%>
        -
        <input name="sy_to" type="text" size="4" maxlength="4" value="<%=strTemp%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" readonly="yes">
	  &nbsp;&nbsp;&nbsp;
<select name="semester">
<%
	strTemp = WI.fillTextValue("semester");
	if(request.getParameter("search_") == null && strTemp.length() ==0) 
		strTemp = (String)request.getSession(false).getAttribute("cur_sem");
%>
	<%=dbOP.loadSemester(bolIsBasic, strTemp, request)%>
        </select>	  </td>
    </tr>
<%if(!bolIsBasic) {%>
    <tr> 
      <td height="26">&nbsp;</td>
      <td height="26">Course</td>
      <td height="26" valign="bottom"><select name="course_index">
        <option value="">N/A</option>
        <%=dbOP.loadCombo("course_index","course_name"," from course_offered where IS_DEL=0 and is_valid=1 "+
 										" order by course_name asc", request.getParameter("course_index"), false)%>
      </select></td>
    </tr>
<%}%>
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
          <option>Firstname</option>
          <option>Course </option>
          <option>College</option>
        </select> <select name="select6">
          <option>Ascending</option>
          <option>Descending</option>
        </select>
        2) 
        <select name="select4">
          <option>Lastname</option>
          <option>Firstname</option>
          <option>Course </option>
          <option>College</option>
        </select> <select name="select7">
          <option>Ascending</option>
          <option>Descending</option>
        </select> </td>
    </tr>
    <tr> 
      <td height="38">&nbsp;</td>
      <td height="38" colspan="4">3) 
        <select name="select10">
          <option>Lastname</option>
          <option>Firstname</option>
          <option>Course </option>
          <option>College</option>
        </select> <select name="select8">
          <option>Ascending</option>
          <option>Descending</option>
        </select>
        4) 
        <select name="select11">
          <option>Lastname</option>
          <option>Firstname</option>
          <option>Course </option>
          <option>College</option>
        </select> <select name="select9">
          <option>Ascending</option>
          <option>Descending</option>
        </select> </td>
    </tr>
-->    <tr> 
      <td height="32"><div align="center"><font size="1"></font></div></td>
      <td height="32">&nbsp;</td>
      <td height="32" valign="bottom"><a href="../../../ADMIN_STAFF/accounting/transaction/petty_cash/petty_cash.htm"></a> 
          <input name="image" type="image" onClick="document.form_.search_.value='1'" src="../../../images/form_proceed.gif" border="0">      </td>
    </tr>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
    <tr> 
      <td height="26" colspan="3"><div align="right"><font size="1"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" border="0"></a>click 
          to PRINT Search Result</font></div></td>
    </tr>
  </table>
	  
  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="thinborder" id="myADTable2">
    <tr> 
      <td height="25" colspan="8" class="thinborder"><div align="center"><strong>:: 
          SEARCH RESULT :: </strong></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4" class="thinborder"><font size="1"><strong>TOTAL : <%=vRetResult.size()/10%></strong></font></td>
      <td height="25" colspan="4" class="thinborder" style="font-size:9px;" align="right">Date and time printed : <%=WI.getTodaysDateTime()%>&nbsp;&nbsp;</td>
    </tr>
    <tr> 
      <td width="4%" height="25" class="thinborder" align="center" style="font-size:9px; font-weight:bold;">COUNT</td>
      <td width="23%" class="thinborder" align="center" style="font-size:9px; font-weight:bold;">STUDENT NAME</td>
      <td width="10%" class="thinborder" align="center" style="font-size:9px; font-weight:bold;">COURSE/YEAR</td>
      <td width="13%" class="thinborder" align="center" style="font-size:9px; font-weight:bold;">REASON(S) FOR FOLLOW-UP</td>
      <td width="12%" class="thinborder" align="center" style="font-size:9px; font-weight:bold;">STRATEGY</td>
      <td width="14%" class="thinborder" align="center" style="font-size:9px; font-weight:bold;">STUDENT'S REMARKS</td>
      <td width="16%" class="thinborder" align="center" style="font-size:9px; font-weight:bold;">COUNSELOR'S REMARK</td>
      <td width="8%" class="thinborder"  align="center" style="font-size:9px; font-weight:bold;">DATE FOLLOWED UP</td>
    </tr>
<%for(int i = 0; i < vRetResult.size(); i += 10){%>
    <tr> 
      <td height="25" style="font-size:9px;" class="thinborder"><%=i/10 + 1%>.</td>
      <td style="font-size:9px;" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 1), "&nbsp;")%></td>
      <td style="font-size:9px;" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 6), "&nbsp;")%></td>
      <td style="font-size:9px;" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 9), "&nbsp;")%></td>
      <td style="font-size:9px;" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 5), "&nbsp;")%></td>
      <td style="font-size:9px;" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 7), "&nbsp;")%></td>
      <td style="font-size:9px;" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 8), "&nbsp;")%></td>
      <td style="font-size:9px;" class="thinborder"><%=WI.getStrValue(vRetResult.elementAt(i + 4), "&nbsp;")%></td>
    </tr>
<%}%>

<%}//end of vRetResult is not null.%>
  </table>

<input type="hidden" name="search_" value="<%=WI.fillTextValue("search_")%>">
<input type="hidden" name="is_basic" value="<%=WI.fillTextValue("is_basic")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>