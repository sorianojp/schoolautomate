<%@ page language="java" import="utility.*,java.util.Vector "%>
<%
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
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="JavaScript">

function ReloadPage(){
	document.form_.page_action.value="";
	this.SubmitOnce("form_");
}

function AddRecord(){
	document.form_.page_action.value="1";
	document.form_.hide_save.src = "../../../images/blank.gif";
	document.form_.submit();
}

function EditRecord()
{
	document.form_.page_action.value="2";
	document.form_.submit();
}

function DeleteRecord(index)
{
	document.form_.page_action.value="0";
	document.form_.info_index.value = index;
	document.form_.submit();
}

function CancelEdit()
{
	location = "./training_schedule.jsp";
}

function PrepareToEdit(index){
	if (document.form_.training_type_index.length)
	document.form_.training_type_index.selectedIndex = 0;
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = index;
	document.form_.submit();
}

</script>
<body bgcolor="#663300" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR Management-Training Mgt","training_schedule.jsp");

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
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
											(String)request.getSession(false).getAttribute("userId"),
											"HR Management","TRAINING MANAGEMENT",
											request.getRemoteAddr(),"training_schedule.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home",
	"../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
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
Vector vEditInfo = null;

hr.HRMandatoryTrng cft = new hr.HRMandatoryTrng();
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
 
if (WI.fillTextValue("page_action").compareTo("0") == 0){
	if (cft.operateOnSchedule(dbOP,request,0) == null){
		strErrMsg = cft.getErrMsg();
	}else{
		strErrMsg = "Training schedule removed successfully";
	}	
}else if (WI.fillTextValue("page_action").equals("1")){
	if (cft.operateOnSchedule(dbOP,request,1) == null){
		strErrMsg = cft.getErrMsg();
	}else{
		strErrMsg = "Training schedule added successfully";
	}	
}else if (WI.fillTextValue("page_action").equals("2")){
	if (cft.operateOnSchedule(dbOP,request,2) == null){
		strErrMsg = cft.getErrMsg();
	}else{
		strErrMsg = "Training schedule edited successfully";
		strPrepareToEdit = "";
	}	
}

if (strPrepareToEdit.equals("1")){
	vEditInfo = cft.operateOnSchedule(dbOP, request,3);	
	if (vEditInfo == null) 
		strErrMsg = cft.getErrMsg();
}

if (WI.fillTextValue("view_5").equals("1")) {
	vRetResult = cft.operateOnSchedule(dbOP,request,5);
	if (vRetResult == null) 
		strErrMsg = cft.getErrMsg();
}else{
	vRetResult = cft.operateOnSchedule(dbOP,request,4);
}


%>
<form action="" method="post" name="form_">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A" class="footerDynamic">
      <td height="25" colspan="5" align="center" bgcolor="#A49A6A"><font color="#FFFFFF" ><strong>:::: 
          TRAININGS/SEMINARS ::::</strong></font></td>
    </tr>
    <tr bgcolor="#A49A6A" >
      <td height="25" colspan="5" bgcolor="#FFFFFF">
	  	<strong>&nbsp;<%=WI.getStrValue(strErrMsg,"<font size=\"3\" color=\"#FF0000\">","</font>","")%></strong></td>
    </tr>
</table>

<% if (!WI.fillTextValue("view_5").equals("1")) { %>
  <table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td>&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td width="125">Type of Training </td>
      <td width="502">	  
	  	<select name="training_type_index" onChange="ReloadPage()">
          <option value="">Select Training Type</option>
          <%=dbOP.loadCombo("TRAINING_TYPE_INDEX","TRAINING_TYPE"," FROM HR_PRELOAD_TRAINING_TYPE order by TRAINING_TYPE",WI.fillTextValue("training_type_index"),false)%>
        </select><font size="1">(optional, filter only)</font></td>
    </tr>
    <tr>
      <td>&nbsp;</td>
      <td>Name of Training</td>
      <td>&nbsp;</td>
    </tr>
    <tr>
      <td width="31">&nbsp;</td>
<% if (vEditInfo != null) 
		strTemp = (String)vEditInfo.elementAt(1);
	else
		strTemp = WI.fillTextValue("mand_training_index");
%>       <td colspan="2"><select name="mand_training_index" >
          <option value="">Select Training Name</option>
          <%=dbOP.loadCombo("MAND_TRAINING_INDEX","MAND_TRAINING_NAME",
	  				" FROM hr_mand_training_name where is_del = 0 and is_valid = 1 " + 
					WI.getStrValue(request.getParameter("training_type_index"),
					" and TRAINING_TYPE_INDEX = ","","") + 
					" order by MAND_TRAINING_NAME",strTemp,false)%>
      </select></td>
    </tr>
    <tr>
      <td width="31">&nbsp;</td>
      <td>Location</td>
<% if (vEditInfo != null) 
		strTemp = (String)vEditInfo.elementAt(2);
	else
		strTemp = WI.fillTextValue("location");
%> 
      <td><input name="location" type= "text" class="textbox" size="64" maxlength="512"
	  		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			value= "<%=strTemp%>"></td>
    </tr>
    <tr>
      <td width="31">&nbsp;</td>
      <td>Inclusive Dates</td>
<% if (vEditInfo != null) 
		strTemp = (String)vEditInfo.elementAt(3);
	else
		strTemp = WI.fillTextValue("schedule");
%> 	  
      <td><input name="schedule" type= "text" class="textbox" size="64" maxlength="512"
	     onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
		 value= "<%=strTemp%>"></td>
    </tr>
    <tr>
      <td colspan="3" align="center">&nbsp;</td>
    </tr>
    <tr>
      <td colspan="3" align="center"><% if (iAccessLevel > 1){
				if(strPrepareToEdit.length() == 0) {%>
          <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a> <font size="1">click to save entries</font>
          <%}else{%>
          <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a><font size="1">click 
            to save changes</font><a href='javascript:CancelEdit()'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
              to cancel and clear entries</font>
                      <%}}%>      </td>
    </tr>
    <tr>
      <td colspan="3" align="center">&nbsp;</td>
    </tr>
  </table>
<% } if (vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#CCCCCC">
      <td height="25" colspan="5" align="center" class="thinborder"><strong>SCHEDULE TRAINING RECORDS </strong></td>
    </tr>
    <tr>
      <td width="35%" height="20" align="center" class="thinborder"><strong>TRAINING NAME </strong></td>
      <td width="52%" align="center" class="thinborder"><strong>VENUE / DATE </strong></td>
      <td colspan="2" align="center" class="thinborder">&nbsp;</td>
    </tr>
<% 	String strCurrMandTraining = "";
	for (int i = 0; i < vRetResult.size() ; i +=5) {
	
		if (strCurrMandTraining.equals((String)vRetResult.elementAt(i+1))){
			strTemp = "";
		}else{
			strCurrMandTraining = (String)vRetResult.elementAt(i+1);
			strTemp = (String)vRetResult.elementAt(i+4);
		}

 %>
    <tr>
      <td class="thinborder">&nbsp;<%=strTemp%></td>
<%
	strTemp ="";
	if ((String)vRetResult.elementAt(i+3) != null) 
		strTemp =(String)vRetResult.elementAt(i+3);
	if ((String)vRetResult.elementAt(i+2) != null) 
		strTemp +="<br>::: "  + (String)vRetResult.elementAt(i+2);
	
		
%>
      <td class="thinborder"> <%=WI.getStrValue(strTemp,"&nbsp;")%> </td>
      <td width="6%" align="center" class="thinborder">
<% if (iAccessLevel > 1 && !WI.fillTextValue("view_5").equals("1")) {%> 
	  <a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/edit.gif" border="0"></a>
<%}else{%>N/A <%}%> 	  
	  </td>
      <td width="7%" align="center" class="thinborder">
<% if (iAccessLevel == 2) {%> 
	  <a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>')"><img src="../../../images/delete.gif" border="0"></a>
<%}else{%> NA <%}%>
	  </td>
    </tr>
    <%}// end for loop %>
  </table>
<%} %> 
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
	<% if (WI.fillTextValue("view_5").equals("1"))
			strTemp = "checked";
		else
			strTemp = ""; %>
			
	
      <td width="27%" height="30" align="center"><input name="view_5" type="checkbox" value="1" onClick="ReloadPage()" <%=strTemp%>>
click to view history</td>
      <td width="73%" align="center">&nbsp;</td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr bgcolor="#FFFFFF">
      <td height="25"  colspan="3" class="footerDynamic">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>

