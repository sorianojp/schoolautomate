<%@ page language="java" import="utility.*,java.util.Vector,hr.HRCareerFeedback" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>HR Assessment</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
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
<script language="JavaScript">


function ReloadPage(){	
	document.staff_profile.submit();
}

function AddRecord(index){

	document.staff_profile.page_action.value="1";
	document.staff_profile.sublevel.value=index;
	if (index == 0){
		document.staff_profile.sub_index_value.value=document.staff_profile.main_value.value;
		document.staff_profile.main_value.value = "";
	}
	else
	{
		document.staff_profile.sub_index_value.value=document.staff_profile.sub_value.value;
		document.staff_profile.sub_value.value="";
	}
	document.staff_profile.submit();
}

function EditRecord(index){

	document.staff_profile.page_action.value="2";
	document.staff_profile.sublevel.value=index;
	if (index == 0){
		document.staff_profile.sub_index_value.value=document.staff_profile.main_value.value;
		document.staff_profile.info_index.value = document.staff_profile.main_index[document.staff_profile.main_index.selectedIndex].value;
	}
	else
	{
		document.staff_profile.sub_index_value.value=document.staff_profile.sub_value.value;
		document.staff_profile.info_index.value = document.staff_profile.sub_index[document.staff_profile.sub_index.selectedIndex].value;
	}
	document.staff_profile.submit();
}

function DeleteRecord(index){

	document.staff_profile.page_action.value="0";
	document.staff_profile.sublevel.value=index;
	if (index == 0){
		document.staff_profile.info_index.value = document.staff_profile.main_index[document.staff_profile.main_index.selectedIndex].value;
		document.staff_profile.main_value.value ="";
	}
	else
	{
		document.staff_profile.info_index.value = document.staff_profile.sub_index[document.staff_profile.sub_index.selectedIndex].value;
		document.staff_profile.sub_value.value ="";
	}
	document.staff_profile.submit();
}


function ChangeMainSelect(){
	if(document.staff_profile.main_index.selectedIndex >0)
		document.staff_profile.main_value.value = document.staff_profile.main_index[document.staff_profile.main_index.selectedIndex].text;
	else
		document.staff_profile.main_value.value = "";
	document.staff_profile.main_index_changed.value = "1";
	ReloadPage();
}

function ChangeSubSelect(){
	if(document.staff_profile.sub_index.selectedIndex >0)
		document.staff_profile.sub_value.value = document.staff_profile.sub_index[document.staff_profile.sub_index.selectedIndex].text;
	else
		document.staff_profile.sub_value.value = "";
	ReloadPage();
}

function ToggleDescriptive(){
	document.staff_profile.submit();
}


</script>
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
								"Admin/Staff-HR-CAREER DEVELOPMENT","hr_career_feedback_create.jsp");
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
														"HR Management","CAREER DEVELOPMENT",request.getRemoteAddr(),
														"hr_career_feedback_create.jsp");
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
String strPrepareToEdit = null;
boolean bNoError = true;
boolean bSetEdit = false;  // to be set when preparetoedit is 1 and okey to edit
String strInfoIndex = request.getParameter("info_index");


HRCareerFeedback hrS = new HRCareerFeedback();
int iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"3"));

if (iAction == 1) {
	vRetResult = hrS.operateOnCareerFeedback(dbOP,request,1);
	if (vRetResult != null){
		strErrMsg = "Career feedback item added successfully";
	}else{
		strErrMsg = hrS.getErrMsg();
	}
}else if (iAction == 2){
	vRetResult = hrS.operateOnCareerFeedback(dbOP,request,2);
	if (vRetResult != null)
		strErrMsg = "Career Feedback item edited successfully";
	else
		strErrMsg = hrS.getErrMsg();
}else if (iAction == 0){
	vRetResult = hrS.operateOnCareerFeedback(dbOP,request,0);
	if (vRetResult != null)
		strErrMsg = "Career Feedback item removed successfully";
	else
		strErrMsg = hrS.getErrMsg();
}

%>

<body bgcolor="#663300" class="bgDynamic">
<form action="" method="post" name="staff_profile">
<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="5" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          CAREER FEEDBACK MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
</table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td> <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
        <br>
        <strong><%=WI.getStrValue(strErrMsg,"")%></strong> 
        <table width="85%" border="0" align="center" cellpadding="2" cellspacing="3">
          <tr> 
            <td height="25"><a href="javascript:ReloadPage()"><img src="../../../images/refresh.gif" border="0"></a> 
              <font size="1">Click to refresh the page.</font></td>
          </tr>
        </table>
        <table width="85%" border="0" align="center" cellpadding="2" cellspacing="3">
          <tr> 
            <td height="25" colspan="2"><strong><font color="#0000FF" size="1">AVAILABLE 
              MAIN ITEMS</font></strong></td>
          </tr>
<%
	strTemp = WI.fillTextValue("main_index");
%>
          <tr> 
            <td width="1%" height="25"><strong></strong></td>
            <td width="99%"> <select name="main_index" id="main_index" onChange="ChangeMainSelect();">
                <option value="" selected>Select/Add Main Item</option>
                <%=dbOP.loadCombo("CF_MAIN_INDEX","CF_MAIN"," FROM HR_CF_MAIN where is_del=0 and is_valid=1",strTemp,false)%> 
              </select></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td><textarea name="main_value" cols="40" rows="2" class="textbox" id="main_value"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=WI.fillTextValue("main_value")%></textarea></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td><font size="1" >
              <%  if (iAccessLevel > 1){
		if (WI.fillTextValue("main_value").length() ==0){%>
              <a href="javascript:AddRecord('0');"><img src="../../../images/add.gif" width="42" height="32" border="0"></a> 
              click to add new ITEM 
              <%}else{ %>
              <a href="javascript:EditRecord('0');"><img src="../../../images/edit.gif" border="0"></a> 
              click to edit ITEM 
              <%	if (iAccessLevel==2) {%>
              <a href="javascript:DeleteRecord('0');"><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>click 
              to delete selected ITEM 
              <%}}}%>
              </font></td>
          </tr>
        </table>
<% if (WI.fillTextValue("main_index").length() != 0) {%>
        <table width="85%" border="0" align="center" cellpadding="2" cellspacing="3">
          <tr> 
            <td height="31"><strong><font color="#0000FF" size="1">AVAILABLE SUB 
              ITEM UNDER MAIN ITEM (<%=WI.fillTextValue("main_value").toUpperCase()%>)</font></strong></td>
          </tr>
<% strTemp =  WI.fillTextValue("sub_index"); %>
          <tr> 
            <td width="93%" height="25"><select name="sub_index" id="sub_index"  onChange="ChangeSubSelect()">
                <option value="">Select/Add Sub Item</option>
                <%=dbOP.loadCombo("CF_SUB_INDEX","CF_SUB"," FROM HR_CF_SUB where is_del=0 and is_valid=1 and CF_MAIN_INDEX = "+ WI.fillTextValue("main_index"),strTemp,false)%>
              </select></td>
          </tr>
<% strTemp  = WI.fillTextValue("descriptive");
	if (strTemp.compareTo("1") == 0 )
		strTemp = "checked";
	else
		strTemp = "";
%>
          <tr> 
            <td height="25"> <input name="descriptive" type="checkbox" id="descriptive" value="1" onClick="ToggleDescriptive()"  <%=strTemp%>>
              Tick if Sub ITEM is descriptive </td>
          </tr>
<%
	if  (WI.fillTextValue("main_index_changed").compareTo("1") == 0){
		strTemp = "";
	}else{
		strTemp = WI.fillTextValue("sub_value");
	}
	if (WI.fillTextValue("descriptive").length() ==  0){
%>
          <tr> 
            <td height="25"><textarea name="sub_value" cols="40" rows="2"  class="textbox" id="sub_value"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
          </tr>
<%}else{%>
          <tr> 
            <td height="25"><input name="sub_value" type="text" class="textbox" id="sub_value"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" value="<%=strTemp%>" size="64"></td>
          </tr>
<%}%>
          <tr> 
            <td height="25"> <%  if (iAccessLevel > 1){
		if (strTemp.length() ==0){%>
              <a href="javascript:AddRecord('1');"><img src="../../../images/add.gif" name="image" width="42" height="32" border="0" type="image"></a> 
              <font size="1">click to add new ITEM 
              <%}else{ %>
              <a href="javascript:EditRecord('1');"><img name="image2" src="../../../images/edit.gif" border="0"></a> 
              click to edit ITEM 
              <%	if (iAccessLevel==2) {%>
              <a href="javascript:DeleteRecord('1');"><img src="../../../images/delete.gif" width="55" height="28" border="0"></a> 
              click to delete selected ITEM </font>
              <%}}}%></td>
          </tr>
        </table>
<% } //end if (WI.fillTextValue("main_value") != 0
	vRetResult = hrS.operateOnCareerFeedback(dbOP,request,4);
	if (vRetResult !=null && vRetResult.size() > 0) {
 %>
        <table width="85%" border="0" align="center" cellpadding="2" cellspacing="3">
          <tr> 
            <td colspan="2">&nbsp;</td>
          </tr>
          <tr> 
            <td colspan="2"> <div align="center"> 
                <p><strong>CAREER FEEDBACK EVALUATION</strong></p>
              </div></td>
          </tr>
<% for (int i=0; i < vRetResult.size(); i+=5) {
	if ((String)vRetResult.elementAt(i+1) !=null) {%>
          <tr> 
            <td colspan="2" bgcolor="#CCCCCC"><font color="#FF0000"> <strong><%=(String)vRetResult.elementAt(i+1)%></strong></font></td>
          </tr>
<%} strTemp = WI.getStrValue((String)vRetResult.elementAt(i+3),"");
	if (strTemp.length() == 0) 
		strTemp = "&nbsp";
	else
		if ((String)vRetResult.elementAt(i+4) != null){
			strTemp = "( " + strTemp + " )";
		}
%>
          <tr> 
            <td width="5%">&nbsp;</td>
            <td width="95%"><%=strTemp%></td>
          </tr>
<%} // end for loop%>
        </table>
<%} // end vRetResult!=null %>
        
      </td>
    </tr>
  </table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
  
<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
<input type="hidden" name="page_action">
<input type="hidden" name="sublevel">
<input type="hidden" name="reloadPage">
<input type="hidden" name="main_index_changed">
<input type="hidden" name="sub_index_value">
</form>
</body>
</html>

