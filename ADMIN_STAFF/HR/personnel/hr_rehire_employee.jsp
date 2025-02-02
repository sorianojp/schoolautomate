<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoExitInterview,hr.HRInfoServiceRecord"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

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
function viewInfo(){
	this.SubmitOnce("staff_profile");
}

function AddRecord(){
	document.staff_profile.page_action.value="1";
	document.staff_profile.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce("staff_profile");
}

function EditRecord(){

	document.staff_profile.page_action.value="2";
	this.SubmitOnce("staff_profile");
}

function DeleteRecord(strInfoIndex){
	document.staff_profile.info_index.value=strInfoIndex;
	document.staff_profile.page_action.value="0";
	this.SubmitOnce("staff_profile");	
}

function PrepareToEdit(strInfoIndex){
	document.staff_profile.info_index.value =strInfoIndex;
	document.staff_profile.prepareToEdit.value="1";
	this.SubmitOnce("staff_profile");
}


function CancelRecord(strEmpID){
	location = "./hr_rehire_employee.jsp";
}

function FocusID() {
	if (document.staff_profile.emp_index)
		document.staff_profile.emp_index.focus();
}

function OpenConfirmation(strInfoIndex){
	var pgLoc = "./hr_rehire_emp_confirm.jsp?info_index="+strInfoIndex;
	var win=window.open(pgLoc,"Confirmation",'width=600,height=400,top=20,left=20,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ajaxLoadSeparated(strSkip) {
	var vIncEoc = "";
	if(document.staff_profile.include_eoc && document.staff_profile.include_eoc.checked)
		vIncEoc = "1";
	
	var strCompleteName = document.staff_profile.filter_.value;
 	
	var objCOAInput = document.getElementById("separated_"); 
// 	if(strCompleteName.length <= 2 && strSkip == '1') {
//		return ;
//	}

	this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=3006&inc_eoc="+vIncEoc+
						 	 "&sel_name=emp_index&filter_="+escape(strCompleteName);

	this.processRequest(strURL);
}
</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;


//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Education","hr_rehire_employee.jsp");

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
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"hr_rehire_employee.jsp");
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp == null) 
	strTemp = "";
//

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

HRInfoExitInterview hrPx = new HRInfoExitInterview();

Vector vRetResult = null;

Vector vEmpList = hrPx.operateOnRehire(dbOP,request,5);

if (vEmpList == null){
	strErrMsg = hrPx.getErrMsg();
}

Vector vEditInfo = null;

String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

int iAction =  -1;

iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"4"));


if (iAction == 1 || iAction  == 2 || iAction==0)
	vRetResult = hrPx.operateOnRehire(dbOP,request,iAction);

switch(iAction){
	case 0:{
		if (vRetResult != null)
			strErrMsg = " Employe rehire record removed successfully";
		else
			strErrMsg = hrPx.getErrMsg();

		break;
	}
	case 1:{ // add Record
		if (vRetResult != null)
			strErrMsg = " Employee rehire record save successfully";
		else
			strErrMsg = hrPx.getErrMsg();

		break;
	}
	case 2:{ //  edit record
		if (vRetResult != null){
			strErrMsg = " Employee rehire record updated successfully";
			strPrepareToEdit = "";
		}else
			strErrMsg = hrPx.getErrMsg();
	}
} //end switch

if (strPrepareToEdit.equals("1")){
	vEditInfo = hrPx.operateOnRehire(dbOP,request,3);
	if (vEditInfo == null)
		strErrMsg = hrPx.getErrMsg();

}

vRetResult = hrPx.operateOnRehire(dbOP,request,4);
if (vRetResult == null && strErrMsg == null){
	strErrMsg= hrPx.getErrMsg();
}
%>
<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">	
<form action="./hr_rehire_employee.jsp" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>::::
          EMPLOYEE RE-HIRE PAGE::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25" colspan="3">&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>

  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="100%"><hr size="1"> <img src="../../../images/sidebar.gif" width="11" height="270" align="right"><br>
        <table width="74%" border="0" align="center" cellpadding="2" cellspacing="0">
          <tr>
            <td>Employee ID </td>
            <td height="25">
<% 
	if (vEmpList != null && vEmpList.size() > 0) {%>
			<label id="separated_">
			<select name="emp_index">
<%  
	if (vEditInfo != null && vEditInfo.size() > 0) 
		strTemp = (String)vEditInfo.elementAt(0);
	else
		strTemp = WI.fillTextValue("emp_index");

	for (int j =0; j < vEmpList.size(); j+=4){
	

	if (strTemp.equals((String)vEmpList.elementAt(j))){
%>
	<option value="<%=(String)vEmpList.elementAt(j)%>" selected>
		<%=(String)vEmpList.elementAt(j+2)+"("+(String)vEmpList.elementAt(j+1) + ") "%>	</option>
<%}else{%>			
	<option value="<%=(String)vEmpList.elementAt(j)%>"> 
		<%=(String)vEmpList.elementAt(j+2)+"("+(String)vEmpList.elementAt(j+1) + ") "%>	</option>
<%} // end if else
}  // end for loop
%> 
            </select>
						</label>
<%}%></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td><input type="text" name="filter_" value="<%=WI.fillTextValue("filter_")%>" size="16" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:12px" 
			onKeyUp = "ajaxLoadSeparated('1');">
              <%
						strTemp = WI.fillTextValue("include_eoc");
						if(strTemp.length() > 0)
							strTemp = "checked";
						else
							strTemp = "";
						%>
              <input type="checkbox" name="include_eoc" value="1" <%=strTemp%> onClick="ajaxLoadSeparated('0');">
Include End of Contract employees </td>
          </tr>
          <tr> 
            <td width="23%">Date of Re-hire </td>
         <% 
		 	if (vEditInfo != null)
				strTemp =  WI.getStrValue((String)vEditInfo.elementAt(2));
			else 
				strTemp = WI.fillTextValue("date_rehire"); 
		%>
            <td width="77%"> 
			<input name="date_rehire" type="text" class="textbox"  size="15"
			onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			onKeyUp="AllowOnlyIntegerExtn('staff_profile','date_rehire','/')" value="<%=strTemp%>"> 
			
            <a href="javascript:show_calendar('staff_profile.date_rehire');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a> 
              &nbsp;</td>
          </tr>
          <tr> 
            <td>Interviewed by </td>
            <td> <input type="text" name="starts_with2" value="<%=WI.fillTextValue("starts_with2")%>" size="16" class="textbox"
		  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:12px" onKeyUp = "AutoScrollList('staff_profile.starts_with2','staff_profile.interviewer',true);"> 
              <font size="1"> interviewer name</font></td>
          </tr>
          <tr> 
            <td>&nbsp;</td>
            <td> 
			
		<% if (vEditInfo != null) 
				strTemp = WI.getStrValue((String)vEditInfo.elementAt(4));
		    else 
				strTemp = WI.fillTextValue("interviewer");
	
	Vector vTemp = new HRInfoServiceRecord().getSupervisorDetail(dbOP,request,null,null, null);
%> <select name="interviewer">
				<option value=""> N / A</option>
                <%
if(vTemp != null && vTemp.size() > 0){
	for(int i = 0; i < vTemp.size(); i += 2) {
		if(strTemp.equals((String)vTemp.elementAt(i))){%>
                <option value="<%=(String)vTemp.elementAt(i)%>" selected> 
                <%=(String)vTemp.elementAt(i + 1)%></option>
                <%}else{%>
                <option value="<%=(String)vTemp.elementAt(i)%>"> 
                <%=(String)vTemp.elementAt(i + 1)%></option>
                <%}
	}
}%>
              </select> </td>
          </tr>
  
          <tr>
            <td height="15"><div align="right">REMARKS / NOTES </div></td>
            <td height="15">&nbsp;</td>
          </tr>
          <tr>
		  <% 
		  	if (vEditInfo != null && vEditInfo.size() > 0)
				strTemp = WI.getStrValue((String)vEditInfo.elementAt(6));
		    else 
				strTemp = WI.fillTextValue("notes");
			%>				
		  
            <td height="15" colspan="2">
				<div align="center">
				  <textarea name="notes" cols="64" rows="4"  class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea>
		    </div></td>
          </tr>
        </table>
        <table width="92%" border="0" align="center" cellpadding="2" cellspacing="0">
          <tr> 
            <td height="15" colspan="2" valign="bottom">&nbsp;</td>
          </tr>
          <tr> 
            <td colspan="2"><div align="center"> 
                <% if (iAccessLevel > 1){
					if (vEditInfo == null) { %>
                <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
                <font size="1">click to save entries</font> 
                <%}else{%>
                <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a> 
                <font size="1">click to save changes</font> 
                <%} // end if else vEditInfo != null%>
                <font size="1">&nbsp;<a href='javascript:CancelRecord()'><img src="../../../images/cancel.gif" border="0"></a>click 
                to  clear entries</font> 
                <%} // if iAccessLevel > 1%>
              </div></td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
<% 
//System.out.println("vRetResult : " + vRetResult);

if (vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#EDF0FA">
      <td  class="thinborder" width="19%"> <div align="center"><strong>EMPLOYEE NAME</strong> </div></td> 
      <td  class="thinborder" width="13%" height="25"><div align="center"><strong>DATE REHIRE </strong></div></td>
      <td width="10%" class="thinborder"> <div align="center"><strong>CONFIRMED</strong> </div></td>
      <td width="22%" class="thinborder"><div align="center"><strong>INTERVIEWED BY</strong></div></td>
      <td width="23%" class="thinborder"><div align="center"><strong>REMARKS</strong></div></td>
      <td width="6%" class="thinborder"><div align="center"><strong>EDIT</strong></div></td>
      <td width="7%" class="thinborder"><div align="center"><strong>DELETE</strong></div></td>
    </tr>
<% 
	boolean bolIsConfirmed = false;
	for (int i = 0; i < vRetResult.size();i+=8){
		bolIsConfirmed = false;
%>
    <tr>
      <td class="thinborder" height="25">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td> 
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+2))%></td>
<%
	if (((String)vRetResult.elementAt(i+3)).equals("1")){
		bolIsConfirmed = true;
		strTemp = "<img src=\"../../../images/tick.gif\">";
	}else{
		strTemp = "<a href=\"javascript:OpenConfirmation('"+ 
						(String)vRetResult.elementAt(i+7)+"')\">" + 
					 "<img src=\"../../../images/x.gif\" border=\"0\"></a>";
	}
%>
      <td class="thinborder" align="center">&nbsp;
	  <%=strTemp%></td>
      <td class="thinborder" >&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+5))%></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+6))%></td>
      <td class="thinborder">
	  <% if (iAccessLevel > 1 && !bolIsConfirmed){%>
	  <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i+7)%>')">
	  <img src="../../../images/edit.gif" border="0"></a>
	  <%}else{%>
		N/A	  
	  <%}%></td>
      <td class="thinborder">
	  <% if (iAccessLevel == 2 && !bolIsConfirmed){%>
	  <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i+7)%>')"><img src="../../../images/delete.gif" border="0"></a>
	  <%}else{%> N/A <%}%>	  </td>
    </tr>
	<%} //end for loop%>
  </table>
  <%} // if vRetResult != null %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  <input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="setEdit" value="<%%>">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
