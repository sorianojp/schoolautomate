<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoPersonalExtn,hr.HRInfoLeave"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.

String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Leave Forwarding</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
TD{
	font-size: 11px;
}
</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
.fontsize11 {		font-size : 11px;
}
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function AddRecord(){
	document.form_.page_action.value="1";
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}

function ShowAll(){
	document.form_.show_list.value= "1";
	document.form_.submit();
}
function ReloadPage(){
	this.SubmitOnce("form_");
}

function UpdateCheckbox(){
	var iMaxValue = Number(document.form_.emp_count.value);
	
	if (document.form_.select_all.checked) {

		for (var i = 0; i < iMaxValue ; i++){
			eval('document.form_.save_'+i+'.checked=true');
		}
	}else{
		for (var i = 0; i < iMaxValue ; i++){
			eval('document.form_.save_'+i+'.checked=false');
		}
	}
	
}

//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.form_.emp_id.value;
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
	document.form_.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "";
//	document.form_.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}
</script>

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolHasTeam = false;

//add security hehol.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Leave Forwarding","leave_forwarding.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>

		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","LEAVE APPLICATION",request.getRemoteAddr(),
														"leave_forwarding.jsp");

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
Vector vRetResult = null;
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
HRInfoLeave hrPx = new HRInfoLeave();

int iCtr = 0;
int iSearchResult = 0;
int i = 0;

if (WI.fillTextValue("page_action").equals("1")){
	if(hrPx.operateOnAvailableLeave(dbOP, request,1) == null);
		strErrMsg = hrPx.getErrMsg();
}

if (WI.fillTextValue("show_list").equals("1")) {
	vRetResult = hrPx.operateOnAvailableLeave(dbOP, request,4);

	if (vRetResult == null)
		strErrMsg = hrPx.getErrMsg();
	else
		iSearchResult =  hrPx.getSearchCount();
}


boolean bolIsFirstTimeImplementation = false;
 //bolIsFirstTimeImplementation = strSchCode.startsWith("WNU");

//for first time implementation, I have to change here the school code and, change the year of leave - line 196.. 
%>
<body bgcolor="#663300" class="bgDynamic">
<form action="./leave_forwarding.jsp" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr> 
		<td width="100%" height="25" colspan="3" align="center"  bgcolor="#A49A6A" class="footerDynamic">
		  <font color="#FFFFFF" size="2" >
		  <strong>:::: HR :  LEAVE CREDIT FORWARDING ::::</strong>
		  </font></td>
	</tr>
</table>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="23" colspan="5"><font size="2" color="#FF0000"><strong><%=WI.getStrValue(strErrMsg)%></strong></font></td>
    </tr>
<%if(bolIsFirstTimeImplementation){//entry point for first time implementation..%>
    <tr>
      <td height="23" colspan="5" style="font-size:14px; color:#0000FF; font-weight:bold">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <u>Note: (1st) Leave Credit Forwarding for Year: <%=2009%></u>
	  <input type="hidden" name="sy_from" value="2009">
	  <input type="hidden" name="sy_to" value="2010">	  </td>
    </tr>
<%}else{%>    
    <tr>
      <td height="23" colspan="5" style="font-size:14px; color:#0000FF; font-weight:bold">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  <u>Note: Leave Credit Forwarding for Year: <%=WI.getTodaysDate(12)%></u>
	  <input type="hidden" name="sy_from" value="<%=WI.getTodaysDate(12)%>">
	  <input type="hidden" name="sy_to" value="<%=WI.getTodaysDate(12)%>">	  </td>
    </tr>
<%}%>
    <tr>
      <td width="4%" height="24">&nbsp;	</td>
      <td width="17%">Status</td>
      <td width="79%" colspan="3"><select name="pt_ft" onChange="ReloadPage();">
        <option value="">All</option>
        <%if (WI.fillTextValue("pt_ft").equals("0")){%>
        <option value="0" selected>Part-time</option>
        <%}else{%>
        <option value="0">Part-time</option>
        <%}if (WI.fillTextValue("pt_ft").equals("1")){%>
        <option value="1" selected>Full-time</option>
        <%}else{%>
        <option value="1">Full-time</option>
        <%}%>
      </select></td>
    </tr>
		<%if(bolIsSchool){%>
		<tr>
      <td height="24">&nbsp;</td>
      <td>Employee Category</td>
      <td colspan="3">
	   <select name="employee_category" onChange="ReloadPage();">          
        <option value="">All</option>
				<%if (WI.fillTextValue("employee_category").equals("0")){%>
				  <option value="0" selected>Non-Teaching</option>
        <%}else{%>
          <option value="0">Non-Teaching</option>				
        <%}if (WI.fillTextValue("employee_category").equals("1")){%>
          <option value="1" selected>Teaching</option>
        <%}else{%>
          <option value="1">Teaching</option>
        <%}%>
       </select></td>
    </tr>
		<%}%>
    <% 	
	String strCollegeIndex = WI.fillTextValue("c_index");	
	%>
    <tr> 
      <td height="24">&nbsp;</td>
      <td><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td colspan="3"> <select name="c_index" onChange="ShowAll();">
          <option value="">N/A</option>
          <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strCollegeIndex,false)%> </select> </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td>Department/Office</td>
      <td colspan="3">
	  	<select name="d_index" onChange="ShowAll();">
          <option value="">ALL</option>
          <%if (strCollegeIndex.length() == 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and (c_index = 0 or c_index is null)", WI.fillTextValue("d_index"),false)%> 
          <%}else if (strCollegeIndex.length() > 0){%>
          <%=dbOP.loadCombo("d_index","d_name", " from department where is_del= 0 and c_index = " + strCollegeIndex , WI.fillTextValue("d_index"),false)%> 
          <%}%>
        </select>	  </td>
    </tr>
		<%if(bolHasTeam){%>
    <tr>
      <td height="10">&nbsp;</td>
      <td>Team</td>
      <td colspan="3"><select name="team_index">
        <option value="">All</option>
        <%=dbOP.loadCombo("TEAM_INDEX","TEAM_NAME"," from AC_TUN_TEAM where is_valid = 1 " +
													" order by TEAM_NAME", WI.fillTextValue("team_index"), false)%>
      </select></td>
    </tr>
		<%}%>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employee ID </td>
      <td height="10" colspan="3"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
        <label id="coa_info"></label>	  </td>
    </tr>
    <tr> 
      <td height="10" colspan="5"><hr size="1" color="#000000"></td>
    </tr>
    <tr>
      <td height="10" colspan="5">OPTION: (Both options includes non-accumulating leave)</td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" colspan="4">
<%
strTemp = WI.fillTextValue("is_accumulated");
	if(strTemp.compareTo("1") == 0 || strTemp.length() == 0) 
		strTemp = " checked";
	else	
		strTemp = "";	
%>
        <input type="radio" name="is_accumulated" value="1"<%=strTemp%> onClick="ReloadPage();"> Accumulating leaves 
<%
	if(strTemp.length() == 0) 
		strTemp = " checked";
	else	
		strTemp = "";	
%>
<input type="radio" name="is_accumulated" value="0"<%=strTemp%> onClick="ReloadPage();"> Accumulating &amp; Convertible to cash</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="4">
			<%
				if(WI.fillTextValue("view_all").length() > 0){
					strTemp = " checked";				
				}else{
					strTemp = "";
				}
			%>
        <input name="view_all" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();">        View ALL </td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="4">&nbsp;</td>
    </tr>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="4"><input type="button" name="proceed_btn" value=" Proceed " style="font-size:11px; height:28px;border: 1px solid #FF0000;" onClick="javascript:ShowAll();">
        <font size="1">click to display employee list to print.</font></td>
    </tr>		
  </table>	
<% if (vRetResult != null && vRetResult.size() > 0) { %> 
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
	<td colspan="5">&nbsp;</td>
  </tr>
  <%if(WI.fillTextValue("view_all").length() == 0){
	int iPageCount = iSearchResult/ hrPx.defSearchSize;		
	if(iSearchResult %  hrPx.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
    <tr>
      <td colspan="5"><div align="right"><font size="2">Jump To page:
        <select name="jumpto" onChange="ShowAll();">
      <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(i =1; i<= iPageCount; ++i )
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
      </font></div></td>
    </tr>
    <%} // end if pages > 1
		}// end if not view all%>	
  	  
  <tr> 
	<td colspan="5">&nbsp;</td>
  </tr>


<% 
	int k = 0; // index for inner Result;
	Vector vRetLeave = null;

	String[] astrSemester ={"Summer", "1st", "2nd","3rd","4th","Annual"};
	String strCurrentCollDept = "";
	int iEmployeeCount = 1; 
	for (i = 0; i < vRetResult.size() ; i+= 9, iEmployeeCount++){
		vRetLeave = (Vector) vRetResult.elementAt(i+7);
		if (i == 0 || !strCurrentCollDept.equals(WI.getStrValue((String)vRetResult.elementAt(i+4)))) { 
			strCurrentCollDept = WI.getStrValue((String)vRetResult.elementAt(i+4));
		if ( i!= 0){
	%> 
	  <tr> 
		<td height="20" colspan="5" bgcolor="#F2EDE6"><%if(bolIsSchool){%>College<%}else{%>Division<%}%> / Unit : <strong><%=strCurrentCollDept%></strong></td>
	  </tr>
	<% } else { %> 
	  <tr> 
		<td height="20" colspan="4" bgcolor="#F2EDE6"><%if(bolIsSchool){%>College<%}else{%>Division<%}%> / Unit : <strong><%=strCurrentCollDept%></strong></td>
	    <td height="20" bgcolor="#F2EDE6">
          <input type="checkbox" name="select_all" onClick="UpdateCheckbox()">select all		 </td>
	  </tr>
<%}
 }%>
	  <tr> 
		<td width="4%" align="right"><%=iEmployeeCount%>.)&nbsp;</td>
		<td>Name : 
				<font color="#FF0000"><strong>
					<%=(WI.formatName((String)vRetResult.elementAt(i+1),(String)vRetResult.elementAt(i+2),
					(String)vRetResult.elementAt(i+3),4)).toUpperCase()%>
				</strong></font>		 </td>
		<td><strong><%=(String)vRetResult.elementAt(i+8)%></strong></td>
	  <td colspan="2">Date of Employment : <font color="#0000FF"><strong><%=(String)vRetResult.elementAt(i+6)%></strong></font></td>
	  </tr>
<%	
	for (k = 0; k < vRetLeave.size() ; k+= 9 ,iCtr++) {%> 
	  <tr> 
		<td width="4%">&nbsp;</td>
		<td width="39%"> 
			<input type="hidden" name="leave_index_<%=iCtr%>" value="<%=WI.getStrValue((String)vRetLeave.elementAt(k))%>">
			<input type="hidden" name="benefit_index_<%=iCtr%>" value="<%=(String)vRetLeave.elementAt(k + 1)%>">
			<!--coverage_iCtr = number of days/hours new leave-->
			<input type="hidden" name="coverage_<%=iCtr%>" value="<%=(String)vRetLeave.elementAt(k + 4)%>">		</td>
			<!--leave_days_iCtr = available leaves-->
			<input type="hidden" name="leave_days_<%=iCtr%>" value="<%=WI.getStrValue((String)vRetLeave.elementAt(k+3))%>">
			<input type="hidden" name="leave_unit_<%=iCtr%>" value="<%=WI.getStrValue((String)vRetLeave.elementAt(k+6))%>">
			<%
				if(((String)vRetLeave.elementAt(k + 5)).equals("1"))
					strTemp = "New ";
				else
					strTemp = "Unused ";
					
			%>
		<td width="24%"><%=strTemp%><%=(String)vRetLeave.elementAt(k + 2)%></td>
			<%
				if(((String)vRetLeave.elementAt(k + 5)).equals("1"))
					strTemp = (String)vRetLeave.elementAt(k + 4);
				else
					strTemp = (String)vRetLeave.elementAt(k + 3);
					
		 	strTemp2 = WI.getStrValue((String)vRetLeave.elementAt(k + 6));
			if(strTemp2.equals("5"))
				strTemp2 = "hour(s)";
			else
				strTemp2 = "day(s)";
		 %>			
	  <td width="14%"><input type="text" onFocus="style.backgroundColor='#D3EBFF'" class="textbox_noborder"			
		 onBlur="style.backgroundColor='white'"  value="<%=WI.getStrValue(strTemp)%>" 
		 size="3" maxlength="2" name="wala_<%=iCtr%>" <%if(!bolIsFirstTimeImplementation){%>readonly<%}%>
		 style="text-align:right;font-size:11px;">
		 <%=strTemp2%>
		 </td>
	    <td width="19%">
			<input type="hidden" name="user_index_<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i)%>">
      <label for="lbl_<%=iCtr%>">
			<input type="checkbox" name="save_<%=iCtr%>" value="1" id="lbl_<%=iCtr%>"> insert
			</label>
			</td>
	  </tr>
	<%}%>
	  <tr> 
		<td colspan="5">&nbsp;</td>
	  </tr>
<%}%> 
</table> 

<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
          <tr> 
            <td width="2%" height="39">&nbsp;</td>
            <td width="98%" align="center" valign="bottom"> 
              <% if (iAccessLevel > 1){%>
              <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a><font size="1">click to save entries</font>
			  <%}%>		    </td>
          </tr>
  </table>
<%}%>   

  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="page_action" value="">
<input type="hidden" name="show_list" value="<%=WI.fillTextValue("show_list")%>">
<input type="hidden" name="emp_count" value="<%=iCtr%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>

