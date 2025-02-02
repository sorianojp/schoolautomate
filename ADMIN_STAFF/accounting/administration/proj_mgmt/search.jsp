<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="javascript" src="../../../../jscript/date-picker.js"></script>
<script language="javascript" src="../../../../jscript/common.js"></script>
<script language="javascript">
function SearchPage() {
	document.form_.search_page.value = "1";
}
function ChangeProjDate() {
	if(document.form_.proj_date_con.selectedIndex == 1) {
		document.form_.start_date_fr.disabled = true;
		document.form_.start_date_to.disabled = true;
		document.form_.start_date_fr.style.backgroundColor='#EEEEEE';
		document.form_.start_date_to.style.backgroundColor='#EEEEEE';

		document.form_.month_.disabled = false;
		document.form_.year_.disabled = false;		
	}
	else {
		document.form_.start_date_fr.disabled = false;
		document.form_.start_date_to.disabled = false;
		document.form_.start_date_fr.style.backgroundColor='#FFFFFF';
		document.form_.start_date_to.style.backgroundColor='#FFFFFF';

		document.form_.month_.disabled = true;
		document.form_.year_.disabled  = true;		
	}
}
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
	
	alert("Click OK to print this page");
	window.print();
}

</script>
<body onLoad="ChangeProjDate();">
<%@ page language="java" import="utility.*,Accounting.ProjectManagement,java.util.Vector" %>
<%
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Accounting-Administration-Project management(search)","search.jsp");
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
														"Accounting","Administration",request.getRemoteAddr(), 
														"search.jsp");	
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
String[] astrDropListEqual      = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual   = {"equals","starts","ends","contains"};
String[] astrDropListBetween    = {"Between","Equal to","Less than","More than"};
String[] astrDropListValBetween = {"BETWEEN","=",">","<"};//check for between

String[] astrSortByName         = {"Start Date","Expense Account Name","Project Budget", "Project Status","School Year"};
String[] astrSortByVal          = {"start_date","complete_code","BUDGET","PROJECT_STATUS","sy_from"};

int iSearchResult = 0;
	
	ProjectManagement projMgmt = new ProjectManagement(request);	
	Vector vRetResult    = null;
	if(WI.fillTextValue("search_page").length() > 0) {
		vRetResult = projMgmt.searchProject(dbOP, request);
		if(vRetResult == null)
			strErrMsg = projMgmt.getErrMsg();
	}
				//System.out.println(projMgmt.getErrMsg());
%>
<form method="post" action="./search.jsp" name="form_" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" id="myADTable1">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          SEARCH PROJECTS - PROJECT MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="5" style="font-size:13px; color:#FF0000; font-weight:bold"><a href="main.jsp"><img src="../../../../images/go_back.gif" border="0"></a>
	  &nbsp;&nbsp;
	  <%=WI.getStrValue(strErrMsg)%>	  </td>
    </tr>
    <tr>
      <td height="25" width="2%">&nbsp;</td>
      <td width="18%">Project Code :</td>
      <td><select name="proj_code_con" style="font-size:11px;">
          <%=projMgmt.constructGenericDropList(WI.fillTextValue("proj_code_con"),astrDropListEqual,astrDropListValEqual)%> </select>
        <input type="text" name="proj_code" maxlength="16" value="<%=WI.fillTextValue("proj_code")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>Project Total Expense </td>
      <td><select name="tot_expense_con" style="font-size:11px;">
          <%=projMgmt.constructGenericDropList(WI.fillTextValue("tot_expense_con"),astrDropListBetween,astrDropListValBetween)%> </select>
        <input name="tot_expense_fr" type="text" size="12" value="<%=WI.fillTextValue("tot_expense_fr")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','tot_expense_fr');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','tot_expense_fr');">
-
<input name="tot_expense_to" type="text" size="12" value="<%=WI.fillTextValue("tot_expense_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','tot_expense_to');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','tot_expense_to');"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Project Name : </td>
      <td>
      <select name="proj_name_con" style="font-size:11px;">
          <%=projMgmt.constructGenericDropList(WI.fillTextValue("proj_name_con"),astrDropListEqual,astrDropListValEqual)%> </select>
      <input type="text" name="proj_name" maxlength="16" value="<%=WI.fillTextValue("proj_name")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
      <td>Approved Budget :</td>
      <td><select name="budget_con" style="font-size:11px;">
         <%=projMgmt.constructGenericDropList(WI.fillTextValue("budget_con"),astrDropListBetween,astrDropListValBetween)%> </select>
        <input name="budget_fr" type="text" size="12" value="<%=WI.fillTextValue("budget_fr")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','budget_fr');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','budget_fr');">
         -
<input name="budget_to" type="text" size="12" value="<%=WI.fillTextValue("budget_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','budget_to');style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','budget_to');"></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25">Project Start Date : </td>
      <td colspan="3"><select name="proj_date_con" onChange="ChangeProjDate();">
        <option value="0">Specific Date/Range</option>
<%
strTemp = WI.fillTextValue("proj_date_con");
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
        <option value="1"<%=strErrMsg%>>Monthly/Yearly</option>
            </select>
	  <input name="start_date_fr" type="text" size="12" maxlength="12" value="<%=WI.fillTextValue("start_date_fr")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <a href="javascript:show_calendar('form_.start_date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
		to
	  <input name="start_date_to" type="text" size="12" maxlength="12" value="<%=WI.fillTextValue("start_date_to")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
          <a href="javascript:show_calendar('form_.start_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../../images/calendar_new.gif" border="0"></a>
		<select name="month_">
		<option value="-1">All Months</option>
<%=dbOP.loadComboMonth(WI.fillTextValue("month_"))%>
        </select>
        <select name="year_">
<%=dbOP.loadComboYear(WI.fillTextValue("year_"), 5, 1)%>
        </select></td>
    </tr>
    
    
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25"><%if(bolIsSchool){%>SY/ Term<%}else{%>Year<%}%></td>
      <td>
        <input name="sy_from" type="text" size="4" maxlength="4" value="<%=WI.fillTextValue("sy_from")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyPress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
<%if(bolIsSchool){%>
-
<%
strTemp = WI.fillTextValue("term");
%>
<select name="term">
	<option value="">ALL</option>
  <%
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
  <option value="1"<%=strErrMsg%>>1st Sem</option>
  <%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
  <option value="2"<%=strErrMsg%>>2nd Sem</option>
  <%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
  <option value="3"<%=strErrMsg%>>3rd Sem</option>
  <%
if(strTemp.equals("0"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
  <option value="0"<%=strErrMsg%>>Summer</option>
</select>
<%}%>
</td>
      <td>Project Status: </td>
      <td><select name="proj_stat">
	  <option value=""></option>
<%
if(strTemp.equals("1"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
        <option value="1"<%=strErrMsg%>>On-going</option>
<%
if(strTemp.equals("2"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="2"<%=strErrMsg%>>Completed</option>
<%
if(strTemp.equals("3"))
	strErrMsg = " selected";
else	
	strErrMsg = "";
%>
          <option value="3"<%=strErrMsg%>>Stopped</option>
      </select></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Project Charged Account : </td>
      <td colspan="3"><input type="text" name="coa_" maxlength="16" value="<%=WI.fillTextValue("coa_")%>" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></td>
    </tr>
    
    
    <tr> 
      <td height="22">&nbsp;</td>
      <td>SORT BY: </td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="4">
        1.) 
        <select name="sort_by1">
          <option value="">N/A</option>
          <%=projMgmt.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> 
        </select> 
		<select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select>
        &nbsp;&nbsp;2.)
        <select name="sort_by2">
          <option value="">N/A</option>
          <%=projMgmt.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> 
        </select>
		<select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
    </tr>
    
    <tr>
      <td height="26">&nbsp;</td>
      <td height="26" colspan="4">3.)
        <select name="sort_by3">
          <option value="">N/A</option>
          <%=projMgmt.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> 
        </select> 
		<select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select>
&nbsp;&nbsp;4.)
		<select name="sort_by4">
          <option value="">N/A</option>
          <%=projMgmt.constructSortByDropList(WI.fillTextValue("sort_by4"),astrSortByName,astrSortByVal)%> 
        </select>
		<select name="sort_by4_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by4_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select>
</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td height="30" colspan="4" align="center"><input type="submit" name="12022" value=" Search Project " style="font-size:11px; height:24px;border: 1px solid #FF0000;"
		 onClick="document.form_.search_page.value='1'"></td>
    </tr>
    <tr>
      <td height="23">&nbsp;</td>
      <td height="23" colspan="4"><div align="right"><font size="1"><a href="javascript:PrintPg();"><img src="../../../../images/print.gif" border="0"></a>click 
      to PRINT list </font></div></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2" align="center">
	  <font size="2">
      	<strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
      <font size="1"><%=SchoolInformation.getAddressLine1(dbOP,false,false)%></font></font><br>
	  PROJECT MANAGEMENT INFORMATION SHEET
  	  </td>
    </tr>
    <tr>
      <td width="75%" height="25"><font size="1"><strong>Total Projects in Record : <%=vRetResult.size()/14%> </strong></font></td>
      <td width="25%">&nbsp;</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td width="6%" style="font-size:9px; font-weight:bold" align="center" class="thinborder">Project Code </td>
      <td width="14%" style="font-size:9px; font-weight:bold" align="center" class="thinborder">Project Name </td>
      <td width="6%" height="26" style="font-size:9px; font-weight:bold" align="center" class="thinborder">Project Status </td>
      <td width="10%" style="font-size:9px; font-weight:bold" align="center" class="thinborder">Project Date </td>
      <td width="8%" style="font-size:9px; font-weight:bold" align="center" class="thinborder">Beginning Balance</td>
      <td width="8%" style="font-size:9px; font-weight:bold" align="center" class="thinborder">Project Cost </td>
      <td width="12%" style="font-size:9px; font-weight:bold" align="center" class="thinborder">Approved By </td>
      <td width="8%" style="font-size:9px; font-weight:bold" align="center" class="thinborder">Approved Budget </td>
      <td width="12%" style="font-size:9px; font-weight:bold" align="center" class="thinborder">Charged To </td>
      <td width="16%" style="font-size:9px; font-weight:bold" align="center" class="thinborder">Account Name </td>
    </tr>
<%
String[] astrConvertStatus = {"", "On going","Completed","Closed"};
for(int i = 0; i < vRetResult.size(); i += 14){%>
    <tr>
      <td class="thinborder"><%=vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 2)%></td>
      <td height="25" class="thinborder"><%=astrConvertStatus[Integer.parseInt((String)vRetResult.elementAt(i + 5))]%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 3)%><%=WI.getStrValue((String)vRetResult.elementAt(i + 4), " - ",""," - till date")%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(Double.parseDouble(WI.getStrValue(vRetResult.elementAt(i + 10), "0")), true)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(Double.parseDouble(WI.getStrValue(vRetResult.elementAt(i + 11), "0")), true)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 8)%></td>
      <td class="thinborder"><%=CommonUtil.formatFloat(Double.parseDouble(WI.getStrValue(vRetResult.elementAt(i + 9), "0")), true)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 12)%></td>
      <td class="thinborder"><%=vRetResult.elementAt(i + 13)%></td>
    </tr>
<%}%>	
  </table>
<%}%>

  <input type="hidden" name="search_page" values="<%=WI.fillTextValue("search_page")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();%>