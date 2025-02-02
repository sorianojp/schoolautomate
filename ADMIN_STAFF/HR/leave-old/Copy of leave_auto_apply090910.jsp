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
<title>Untitled Document</title>
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


</script>

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;


//add security hehol.

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Leave Application","leave_auto_apply.jsp");


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

int iCtr = 0;


if (WI.fillTextValue("page_action").equals("1")){
	hrPx.insertEmployeeLeave(dbOP, request);
	strErrMsg = hrPx.getErrMsg();
}

if (WI.fillTextValue("show_list").equals("1")) {
	vRetResult = hrPx.getApplicableEmpForLeave(dbOP, request);

	if (vRetResult == null){
		strErrMsg = hrPx.getErrMsg();
	}
}

%>
<body bgcolor="#663300" class="bgDynamic">
<form action="./leave_auto_apply.jsp" method="post" name="form_">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3"  bgcolor="#A49A6A" class="footerDynamic">
	  		<div align="center">
				<font color="#FFFFFF" size="2" >
					<strong>:::: HR :  AUTO CREATE ANNUAL LEAVE CREDITS::::</strong>				</font>			</div>
	  </td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;<strong>
	  			<%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>","")%></strong></td>
    </tr>
    <tr> 
      <td width="10%" height="25">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  Year&nbsp;: 
	  </td>
      <td width="9%"><%
strTemp = WI.fillTextValue("sy_from");
if(strTemp.length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
%> <input name="sy_from" type= "text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  value="<%=WI.getStrValue(strTemp)%>" size="4" maxlength="4" onKeyUp="AllowOnlyInteger('form_','sy_from')"></td>
      <td width="81%">
	  <a href="javascript:ShowAll()"><img src="../../../images/form_proceed.gif" border="0"></a>
	  
	  </td>
    </tr>
  </table>
<% 
	if (vRetResult != null && vRetResult.size() > 0) {
	

%> 
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
  <tr> 
	<td colspan="4">&nbsp;</td>
  </tr>
  <tr> 
	<td colspan="2">&nbsp;&nbsp;<strong>Total Employees :<%=(String)vRetResult.elementAt(0)%></strong></td>
    <% if (WI.fillTextValue("show_all").equals("1"))
			strTemp = "checked";
		else
			strTemp = ""; %>
    <td><input name="show_all" type="checkbox" value="1" <%=strTemp%>  onClick="ShowAll()"> 
      click to show all </td>
    <td>
<% if (!WI.fillTextValue("show_all").equals("1")) {%>	
		Jump To : 
		<select name="jump_to" onChange="ShowAll()">
	<% 	int iMaxList = Integer.parseInt((String)vRetResult.elementAt(0));
		int iPageNumber = 0;
		int iRangeTo = 0;
		for (int j = 1; j < iMaxList; j+=25, iPageNumber++){ 
			iRangeTo = j + 24;
			if (iRangeTo > iMaxList)
				iRangeTo = iMaxList;
			
			if (WI.fillTextValue("jump_to").equals(Integer.toString(iPageNumber))){
	%> 
		<option value="<%=iPageNumber%>" selected><%=j%> - <%=iRangeTo%> </option> 
		<%}else{%>
		<option value="<%=iPageNumber%>"><%=j%> - <%=iRangeTo%> </option> 
		<%} 
		} // end for loop%> 
		</select>
<%}%>&nbsp;	</td>
  </tr>	  
  <tr> 
	<td colspan="4">&nbsp;</td>
  </tr>


<% 
	int k = 0; // index for inner Result;
	Vector vRetLeave = (Vector)vRetResult.elementAt(1);

	String[] astrSemester ={"Summer", "1st", "2nd","3rd","4th","Annual"};
	String strCurrentCollDept = "";
	int iEmployeeCount = 1; 
	for (int i = 2; i < vRetResult.size() ; i+= 5, iEmployeeCount++){
	
		if (i == 2 || !strCurrentCollDept.equals(
							WI.getStrValue((String)vRetResult.elementAt(i+2)))) { 
							
			strCurrentCollDept = 
				WI.getStrValue((String)vRetResult.elementAt(i+2));
	
		if ( i!= 2){
%> 
	  <tr> 
		<td height="20" colspan="4" bgcolor="#F2EDE6"><%if(bolIsSchool){%>College<%}else{%>Division<%}%> / Unit : <strong><%=strCurrentCollDept%></strong></td>
	  </tr>
<%   }else{%> 
	  <tr> 
		<td height="20" colspan="3" bgcolor="#F2EDE6"><%if(bolIsSchool){%>College<%}else{%>Division<%}%> / Unit : <strong><%=strCurrentCollDept%></strong></td>
	    <td height="20" bgcolor="#F2EDE6">
           <input type="checkbox" name="select_all" onClick="UpdateCheckbox()">select all		 
 					</td>
	  </tr>
<%}
 }%>
	  <tr> 
		<td width="4%" align="right"><%=iEmployeeCount%>.)&nbsp;</td>
		<td>Name : 
				<font color="#FF0000"><strong>
					<%=((String)vRetResult.elementAt(i+1)).toUpperCase()%>
				</strong></font>		 </td>
		<td colspan="2">Date of Employment : 
				<font color="#0000FF"><strong><%=(String)vRetResult.elementAt(i+4)%></strong></font></td>
	  </tr>
<% for (k = 0; k < vRetLeave.size() ; k+= 3 ,iCtr++) {%> 
	  <tr> 
		<td width="4%">&nbsp;</td>
		<td width="39%"><input type="hidden" name="semester<%=iCtr%>" 
								value="<%=WI.getStrValue((String)vRetLeave.elementAt(k),"5")%>">
			<input type="hidden" name="benefit_index<%=iCtr%>" 
								value="<%=(String)vRetLeave.elementAt(k+2)%>">								
			Semester : <%=astrSemester[Integer.parseInt(WI.getStrValue((String)vRetLeave.elementAt(k),"5"))]%>		</td>
		<td width="33%">Allowed Leave : 
		<input type="text" onFocus="style.backgroundColor='#D3EBFF'" class="textbox"			
		 onBlur="style.backgroundColor='white'"  value="<%=WI.getStrValue((String)vRetLeave.elementAt(k+1))%>" 
		 size="2" maxlength="2" onKeyUp="AllowOnlyInteger('form_','sy_from')" name="leave_hours<%=iCtr%>"> 
		(hours)		</td>
	    <td width="24%">
			<input type="hidden" name="user_index<%=iCtr%>" value="<%=(String)vRetResult.elementAt(i)%>">
			<input type="checkbox" name="checkbox<%=iCtr%>" value="1"> insert						
		 </td>
	  </tr>
<% } %>
	  <tr> 
		<td colspan="4">&nbsp;</td>
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

