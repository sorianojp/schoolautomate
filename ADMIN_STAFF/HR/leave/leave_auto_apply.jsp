<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoPersonalExtn,
								hr.HRInfoLeave"%>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new CommonUtil().getIsSchool(null)).equals("1"))
	bolIsSchool = true;
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Leave Manual crediting/forwarding</title>
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
</style>
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
function ReloadPage(){
	this.SubmitOnce("form_");
}
function AddRecord(){
	document.form_.page_action.value="1";
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}

function ShowAll(){
	document.form_.show_list.value= "1";
	document.form_.submit();
}

function UpdateCheckbox(){
	var iMaxValue = Number(document.form_.max_display.value);
	
	if (document.form_.select_all.checked) {

		for (var i = 0; i < iMaxValue ; i++){
			eval('document.form_.checkbox'+i+'.checked=true');
		}
	}else{
		for (var i = 0; i < iMaxValue ; i++){
			eval('document.form_.checkbox'+i+'.checked=false');
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
	String strAddlLeave = null;
	boolean bolHasTeam = false;
	boolean bolUseRange = false;
//add security hehol.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Leave Application","leave_auto_apply.jsp");
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		bolHasTeam = (readPropFile.getImageFileExtn("HAS_TEAMS","0")).equals("1");
		bolUseRange = (readPropFile.getImageFileExtn("LEAVE_SCHEDULER","0")).equals("1");
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
														"leave_auto_apply.jsp");

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
//System.out.println("--" + ConversionTable.compareDate("01/01/2010", "2/01/2010"));
//System.out.println("--" + ConversionTable.compareDate("02/01/2010", "1/01/2010"));
//System.out.println("--" + ConversionTable.compareDate("1/01/2010", "1/01/2010"));

int iCtr = 0;
int iSearchResult = 0;

if (WI.fillTextValue("page_action").equals("1")){
 	vRetResult = hrPx.getApplicableEmployeeLeaves(dbOP, request, 1);
	if(vRetResult == null)
		strErrMsg = hrPx.getErrMsg();
}

if (WI.fillTextValue("show_list").equals("1")) {
	vRetResult = hrPx.getApplicableEmployeeLeaves(dbOP, request, 4);

	if (vRetResult == null){
		strErrMsg = hrPx.getErrMsg();
	}else{
		iSearchResult = hrPx.getSearchCount();
	}
}

%>
<body bgcolor="#663300" class="bgDynamic">
<form action="./leave_auto_apply.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td width="100%" height="25" colspan="3" align="center"  bgcolor="#A49A6A" class="footerDynamic">
				<font color="#FFFFFF" size="2" >
			<strong>:::: HR :  CREATE LEAVE CREDITS::::</strong> </font> </td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;<strong>
	  			<%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>","")%></strong></td>
    </tr>
  </table>
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<%if(!bolUseRange){%>
    <tr>
      <td height="24">&nbsp;</td>
      <td>Year</td>
      <td colspan="3">
			<%
				strTemp = WI.fillTextValue("sy_from");
				
				if(strTemp.length() ==0)
					strTemp = WI.getTodaysDate(12);
				//if(strTemp.length() ==0)
				//	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
			%>
        <input name="sy_from" type= "text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  value="<%=WI.getStrValue(strTemp)%>" size="4" maxlength="4" onKeyUp="AllowOnlyInteger('form_','sy_from')"></td>
    </tr>
		<%}%>
    <tr>
      <td width="3%" height="24">&nbsp;	</td>
      <td width="21%">Status</td>
      <td width="76%" colspan="3"><select name="pt_ft" onChange="ReloadPage();">
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
      </select>			</td>
    </tr>
		<%}%>
    
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10">Employee ID </td>
      <td height="10" colspan="3"><input name="emp_id" type="text" size="16" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AjaxMapName(1);">
        <label id="coa_info"></label></td>
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
		<%if(!bolUseRange){%>
    <tr>
      <td height="10">&nbsp;</td>
			<%
				if(WI.fillTextValue("show_new").length() > 0){
					strTemp = " checked";				
				}else{
					strTemp = "";
				}
			%>			
      <td height="10" colspan="4"><input name="show_new" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();">
Show Only Employees hired for this year</td>
    </tr>
		<%}%>
    <tr>
      <td height="10">&nbsp;</td>
      <td height="10" colspan="4">
			<%
				if(WI.fillTextValue("show_all").length() > 0){
					strTemp = " checked";				
				}else{
					strTemp = "";
				}
			%>
        <input name="show_all" type="checkbox" value="1"<%=strTemp%> onClick="ReloadPage();">        
        View ALL Result in single page </td>
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
<%if (vRetResult != null && vRetResult.size() > 0) {%> 
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr>     
    <td width="50%">&nbsp; </td>
		
    <td width="50%" align="right">
		<%		
	if(WI.fillTextValue("show_all").length() == 0){
	int iPageCount = iSearchResult/hrPx.defSearchSize;		
	if(iSearchResult % hrPx.defSearchSize > 0) ++iPageCount;
	if(iPageCount > 1){%>
    <font size="2">Jump To page: 
          <select name="jumpto" onChange="ReloadPage();">
            <%
			strTemp = request.getParameter("jumpto");
			if(strTemp == null || strTemp.trim().length() ==0) strTemp = "0";

			for(int i =1; i<= iPageCount; ++i )
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
      </font>
    <%}
					}%></td>
  </tr>
</table>
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
		<td colspan="5">&nbsp;</td>
  </tr>
<% 
	int k = 0; // index for inner Result;
	Vector vRetLeave = null;

	String[] astrSemester ={"Summer", "1st", "2nd","3rd","4th","Annual"};
	String strCurrentCollDept = "";
	int iEmployeeCount = 1; 
	for (int i = 0; i < vRetResult.size() ; i+= 9, iEmployeeCount++){
		vRetLeave = (Vector) vRetResult.elementAt(i+7);
  		if (i == 0 || !strCurrentCollDept.equals(WI.getStrValue((String)vRetResult.elementAt(i+4)))) { 							
			strCurrentCollDept = WI.getStrValue((String)vRetResult.elementAt(i+4));
	
		if ( i != 0){
%> 
	  <tr> 
		<td height="20" colspan="5" bgcolor="#F2EDE6"><%if(bolIsSchool){%>College<%}else{%>Division<%}%> / Unit : <strong><%=strCurrentCollDept%></strong></td>
	  </tr>
<%   }else{%> 
	  <tr> 
		<td height="20" colspan="4" bgcolor="#F2EDE6"><%if(bolIsSchool){%>College<%}else{%>Division<%}%> / Unit : <strong><%=strCurrentCollDept%></strong></td>
	    <td height="20" bgcolor="#F2EDE6">
           <input type="checkbox" name="select_all" onClick="UpdateCheckbox()">select all			</td>
	  </tr>
<%}
 }%>
	  <tr> 
		<td width="4%" align="right"><%=iEmployeeCount%>.)&nbsp;</td>
		<%
			strTemp = WI.formatName((String)vRetResult.elementAt(i+1), (String)vRetResult.elementAt(i+2), 
															(String)vRetResult.elementAt(i+3), 4);
 		%>
		<td>Name : <font color="#FF0000"><strong><%=strTemp.toUpperCase()%>
				</strong></font>		 </td>
		<td colspan="3">Date of Employment : 
				<font color="#0000FF"><strong><%=(String)vRetResult.elementAt(i+6)%></strong></font></td>
	  </tr>
<% for (k = 0; k < vRetLeave.size() ; k+= 12 ,iCtr++) {%> 
		<input type="hidden" name="doe_<%=iCtr%>" value="<%=WI.getStrValue((String)vRetResult.elementAt(i+6))%>">
		
		<input type="hidden" name="semester_<%=iCtr%>" value="<%=WI.getStrValue((String)vRetLeave.elementAt(k+7),"5")%>">
		<input type="hidden" name="benefit_index_<%=iCtr%>" value="<%=vRetLeave.elementAt(k+1)%>">
		<input type="hidden" name="leave_unit_<%=iCtr%>" value="<%=vRetLeave.elementAt(k+6)%>">		

		<input type="hidden" name="leave_index_<%=iCtr%>" value="<%=WI.getStrValue((String)vRetLeave.elementAt(k))%>">
		<input type="hidden" name="coverage_<%=iCtr%>" value="<%=(String)vRetLeave.elementAt(k + 4)%>">		</td>
		<input type="hidden" name="leave_days_<%=iCtr%>" value="<%=WI.getStrValue((String)vRetLeave.elementAt(k+3))%>">
		<input type="hidden" name="benefit_nature_<%=iCtr%>" value="<%=WI.getStrValue((String)vRetLeave.elementAt(k+11))%>">
	  <tr> 
		<td width="4%">&nbsp;</td>
		<%			
			strTemp = (String)vRetLeave.elementAt(k+7);
 			if(strTemp == null || strTemp.length() == 0)
				strTemp = "Annual ";
			else
				strTemp = "Semester : " + astrSemester[Integer.parseInt(strTemp)];
		%>
		<td width="36%">
								
			<%=strTemp%></td>
			<%
				if(((String)vRetLeave.elementAt(k + 5)).equals("1")){
					strTemp = "New ";
					strTemp2 = (String)vRetLeave.elementAt(k + 4);
				}else{
					strTemp = "Unused ";
					strTemp2 = (String)vRetLeave.elementAt(k + 3);
 				}
		 %>				
		<td width="21%"><%=strTemp%> <%=(String)vRetLeave.elementAt(k + 2)%></td>
        <%
		 	strTemp = WI.getStrValue((String)vRetLeave.elementAt(k + 6));
			if(strTemp.equals("5"))
				strTemp = "hour(s)";
			else
				strTemp = "day(s)";

			strAddlLeave = ConversionTable.replaceString((String)vRetLeave.elementAt(k + 8),",","");

			if(Double.parseDouble(strAddlLeave) == 0d)
				strAddlLeave = "";
		 %>
	    <td width="20%"><input type="text" onFocus="style.backgroundColor='#D3EBFF'" class="textbox"			
		 onBlur="style.backgroundColor='white'"  value="<%=WI.getStrValue(strTemp2)%>" 
		 size="4" maxlength="3" onKeyUp="AllowOnlyIntegerExtn('form_','leave_hours<%=iCtr%>','.')" 
		 name="leave_hours<%=iCtr%>" style="text-align:right" >
      <%=strTemp%> <%=WI.getStrValue(strAddlLeave,"<font color='#FF0000'>+","</font>","")%>
 			</td>
	    <td width="19%">
			<input type="hidden" name="user_index_<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i)%>">
			<input type="checkbox" name="checkbox<%=iCtr%>" value="1"> insert		 </td>
	  </tr>
<% } %>
	  <tr> 
		<td colspan="5">&nbsp;</td>
	  </tr>
<%  }%> 
</table> 

<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
          <tr> 
            <td width="2%" height="51">&nbsp;</td>
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
<input type="hidden" name="max_display" value="<%=iCtr%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>

