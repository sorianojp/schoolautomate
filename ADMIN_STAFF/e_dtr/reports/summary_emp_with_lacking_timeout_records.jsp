<%@ page language="java" import="utility.*,java.util.Vector,eDTR.ReportEDTR, eDTR.eDTRUtil" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(7);

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Employees with Lacking Time-out</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;	
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="Javascript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function PrintPage()
{
	document.dtr_op.print_page.value="1";
	document.dtr_op.submit();
}
	
function ViewRecords()
{
	document.dtr_op.print_page.value="";
	document.dtr_op.reload_page.value="1";
	this.SubmitOnce("dtr_op");	
}
function ReloadPage()
{
	document.dtr_op.print_page.value="";
	this.SubmitOnce("dtr_op");	
}

//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.dtr_op.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.dtr_op.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
	//document.dtr_op.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%	
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	Vector vRetResult = null;
	int iSearchResult =0;
	int iPageCount = 0;
	boolean bolHasTeam = false;

//add security here.

	if (WI.fillTextValue("print_page").compareTo("1")== 0){ %>
	<jsp:forward page="./summary_lacking_time_out_print.jsp" />
<%  return;}
	
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Employees with Lacking Time Out Record",
								"summary_emp_with_lacking_timeout_records.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		%>
		
<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","STATISTICS & REPORTS",request.getRemoteAddr(), 
														"summary_emp_with_lacking_timeout_records.jsp");	
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

ReportEDTR RE = new ReportEDTR(request);

if (WI.fillTextValue("reload_page").compareTo("1")  == 0) {
	vRetResult = RE.getLapseTInTout(dbOP);
	if (vRetResult == null) 
		strErrMsg = RE.getErrMsg();
	else iSearchResult = RE.getSearchCount();
	
	if (RE.defSearchSize  != 0){
		iPageCount = iSearchResult/RE.defSearchSize;
		if(iSearchResult % RE.defSearchSize > 0) ++iPageCount;
	}
}

String[] astrDropListEqual = {"Equal to","Starts with","Ends with","Contains"};
String[] astrDropListValEqual = {"equals","starts","ends","contains"};
if(bolIsSchool)
   strTemp = "College";
else
   strTemp = "Division";
String[] astrSortByName    = {"ID #","Lastname","Firstname", strTemp, "Office/Department"};
String[] astrSortByVal     = {"id_number","lname","fname","c_name","d_name"};
String strSchCode = dbOP.getSchoolIndex();
String[] astrCategory={"Rank and File", "Junior Staff", "Senior Staff", "ManCom", "Consultant"};
%>

<form action="./summary_emp_with_lacking_timeout_records.jsp" method="post" name="dtr_op" >
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="5" align="center" bgcolor="#A49A6A" class="footerDynamic"> <font color="#FFFFFF" ><strong>::: 
      EMPLOYEES WITH LACKING TIME OUT RECORD :::</strong></font></td>
    <tr>
      <td height="25" colspan="5">&nbsp;<%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\"><strong>","</strong></font>","")%></td>
  </table>

  <table width="100%" border="0" cellpadding="5" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td><p><strong> &nbsp;&nbsp;</strong>Date :: &nbsp;From: 
          <input name="from_date" type="text"  id="from_date" size="12" readonly="true"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("from_date")%>">
          <a href="javascript:show_calendar('dtr_op.from_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;To 
          : 
          <input name="to_date" type="text"  id="to_date" size="12" readonly="true" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=WI.fillTextValue("to_date")%>">
          <a href="javascript:show_calendar('dtr_op.to_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></p></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="18%" height="25">Enter Employee ID </td>
      <td width="80%" height="25"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" 
			class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			onKeyUp="AjaxMapName(1);"><label id="coa_info"></label>
      </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="2">
			<table width="100%" border="0" cellspacing="0" cellpadding="0">
<%if(strSchCode.startsWith("AUF")){%>
          <tr> 
            <td height="25">Employment Catg</td>
						<%
							strTemp = WI.fillTextValue("emp_type_catg");
						%>
            <td height="25"><strong> 
              <select name="emp_type_catg" onChange="ReloadPage();">
								<option value="">ALL</option>
								<%
								for(int i = 0;i < astrCategory.length;i++){
									if(strTemp.equals(Integer.toString(i))) {%>
								<option value="<%=i%>" selected><%=astrCategory[i]%></option>
								<%}else{%>
								<option value="<%=i%>"> <%=astrCategory[i]%></option>
								<%}
											}%>
							</select>
              </strong></td>
          </tr>
					<%}%>
          <tr> 
            <td width="19%" height="25">Employment Type</td>
            <td width="81%" height="25"><strong> 
              <select name="emp_type">
                <option value="">ALL</option>
                <%=dbOP.loadCombo("EMP_TYPE_INDEX","EMP_TYPE_NAME"," from HR_EMPLOYMENT_TYPE where IS_DEL=0 " +
								WI.getStrValue(WI.fillTextValue("emp_type_catg"), " and emp_type_catg = " ,"","") +
								" order by EMP_TYPE_NAME asc", WI.fillTextValue("emp_type"), false)%> 
              </select>
              </strong></td>
          </tr>					
          <tr> 
            <td height="25"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
            <td height="25"><select name="c_index" onChange="ReloadPage();">
                <option value="">N/A</option>
                <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", WI.fillTextValue("c_index"), false)%> </select> </td>
          </tr>
          <tr> 
            <td height="25">Office / Department</td>
            <td height="25"> <select name="d_index">
                <option value="">All</option>
                <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 " + 
				WI.getStrValue(request.getParameter("c_index")," and c_index = " ,""," and (c_index is null or c_index = 0)") + 
				" order by d_name asc", WI.fillTextValue("d_index"), false)%> 
              </select> </td>
          </tr>
          <tr>
            <td height="25">Office/Dept filter<br></td>
            <td height="25"><input type="text" name="dept_filter" value="<%=WI.fillTextValue("dept_filter")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
        (enter office/dept's first few characters)</td>
          </tr>
          <tr>
            <td height="25">Team</td>
            <td><select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select></td>
          </tr>
        </table></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18">&nbsp;</td>
      <td>&nbsp;</td>
      <td>&nbsp;</td>
      <td height="18">&nbsp;</td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td width="10%" height="25">SORT BY </td>
      <td width="29%"><select name="sort_by1">
          <option value="">N/A</option>
          <%=RE.constructSortByDropList(WI.fillTextValue("sort_by1"),astrSortByName,astrSortByVal)%> </select> <br> <select name="sort_by1_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by1_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td width="28%"><select name="sort_by2">
          <option value="">N/A</option>
          <%=RE.constructSortByDropList(WI.fillTextValue("sort_by2"),astrSortByName,astrSortByVal)%> </select> <br> <select name="sort_by2_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by2_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
      <td width="31%" height="25"><select name="sort_by3">
          <option value="">N/A</option>
          <%=RE.constructSortByDropList(WI.fillTextValue("sort_by3"),astrSortByName,astrSortByVal)%> </select> <br> <select name="sort_by3_con">
          <option value="asc">Ascending</option>
          <%
if(WI.fillTextValue("sort_by3_con").compareTo("desc") ==0){%>
          <option value="desc" selected>Descending</option>
          <%}else{%>
          <option value="desc">Descending</option>
          <%}%>
        </select></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="12%" height="25">&nbsp;</td>
      <td width="88%" height="25" colspan="2">&nbsp; </td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2"><a href="javascript:ViewRecords();"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr>
      <td height="18">&nbsp;</td>
      <td height="18" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <% if (vRetResult != null) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="56%">&nbsp;&nbsp;<strong>Total : <%=iSearchResult%> 
        <% if (WI.fillTextValue("show_all").compareTo("1") != 0){ %>
        - Showing(<%=RE.getDisplayRange()%>) </strong>&nbsp;&nbsp; &nbsp; 
        <input type="checkbox" name="show_all" value="1"> check to show all 	
        <%}%> </td>
      <td width="29%"> 
        <%
if(iPageCount > 1) {%>
        Jump To page: 
        <select name="jumpto" onChange="ViewRecords();">
          <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for( int i =1; i<= iPageCount; ++i )
			{
				if(i == Integer.parseInt(strTemp) ){%>
          <option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%}else{%>
          <option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
          <%
					}
			}
			%>
        </select> 
        <%}%>
      </td>
      <td width="15%"><a href="javascript:PrintPage()"><img border="0" src="../../../images/print.gif"></a>
        print list</td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#D6E0EB"> 
      <% strTemp = WI.fillTextValue("from_date") + " - " + WI.fillTextValue("to_date"); %>
      <td height="25"  colspan="5" align="center" class="thinborder"> <strong>LIST 
      OF EMPLOYEE WITHOUT TIME OUT (<%=strTemp%>)</strong></td>
    </tr>
    <tr> 
      <td width="14%" class="thinborder"><strong>&nbsp;EMPLOYEE ID</strong></td>
      <td width="32%" class="thinborder"><strong>&nbsp;NAME</strong></td>
      <td width="21%" height="23" align="center" class="thinborder"><strong>DEPT 
        / OFFICE</strong></td>
      <td width="16%" height="23" class="thinborder"><strong>&nbsp;DATE</strong></td>
      <td width="17%" height="23" class="thinborder"><strong> &nbsp;TIME IN </strong></td>
    </tr>
    <%		strTemp = null;
		  		 for (int i=0; i < vRetResult.size(); i+=10)  {%>
    <tr> 
      <% if (strTemp!=null && strTemp.compareTo((String)vRetResult.elementAt(i+1))==0){
		strTemp2 ="&nbsp;";
		strTemp3 ="&nbsp;";
	}else{
		strTemp = (String)vRetResult.elementAt(i+1);
		strTemp2 = (String)vRetResult.elementAt(i+7);
		strTemp3 = WI.formatName((String)vRetResult.elementAt(i+4),(String)vRetResult.elementAt(i+5),
								 (String)vRetResult.elementAt(i+6),4);
	}
%>
      <td class="thinborder">&nbsp;<%=strTemp2%></td>
      <td class="thinborder">&nbsp;<%=strTemp3%></td>
<% 
	strTemp3 = (String)vRetResult.elementAt(i+8);
	if (strTemp3 != null) 
		strTemp3 += WI.getStrValue((String)vRetResult.elementAt(i+9)," :: ","","");
	else strTemp3 = (String)vRetResult.elementAt(i+9);
%>
      <td class="thinborder">&nbsp;<%=strTemp3%></td>
      <td class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+3)%></td>
      <td height="25" class="thinborder"> &nbsp;<%=eDTRUtil.formatTime(((Long)vRetResult.elementAt(i+2)).longValue())%></td>
    </tr>
    <%} //end for loop%>
  </table>
<%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="reload_page" value="0"> 
 <input type="hidden" name="print_page">
</form>
</body>
</html>
<% dbOP.cleanUP(); %>