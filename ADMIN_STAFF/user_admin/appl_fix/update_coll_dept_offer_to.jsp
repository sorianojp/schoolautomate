<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>

<script language="JavaScript">
function ReloadPage()
{
	document.form_.page_reloaded.value="";
	document.form_.reloadPage.value = "1";
	document.form_.showall.value = "1";
	document.form_.page_action.value = "";
	this.SubmitOnce("form_");
}

function showList(){
	document.form_.page_reloaded.value="";
	document.form_.reloadPage.value = "1";
	document.form_.showall.value = "1";
	document.form_.page_action.value = "";
	this.SubmitOnce("form_");
}
function EditRecord(strInfoIndex){
	if(strInfoIndex == '0')
		document.form_.update_all.value = '1';
	else	
		document.form_.page_action.value = "1";	
	document.form_.reloadPage.value = "1";
	document.form_.showall.value = "1";
	document.form_.page_reloaded.value="";
	document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce("form_");
}

function ChangeCollege(){
	document.form_.reloadPage.value = "1";
	document.form_.showall.value = "1";
	document.form_.page_reloaded.value="1";
	document.form_.page_action.value = "";
	this.SubmitOnce("form_");	
}
</script>

<body bgcolor="#D2AE72">
<%@ page language="java" import="utility.*,java.util.Vector" %>
<%

	DBOperation dbOP = null;
	String strErrMsg = "";
	String strTemp = null;
	WebInterface WI = new WebInterface(request);

//add security here.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-System Administrator-Application Fix","update_coll_dept_offer_to.jsp");

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
														"System Administration","Application Fix",request.getRemoteAddr(),
														"update_coll_dept_offer_to.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}

//end of authenticaion code.
Vector vRetResult = null;
Vector vRetCollege = null;
Vector vRetDepartment = null;

if(WI.fillTextValue("update_all").length() > 0) {
	int iMaxDisp = Integer.parseInt(WI.getStrValue(WI.fillTextValue("max_disp"), "0"));
	
	for(int i = 0; i < iMaxDisp; ++i) {
		if(WI.fillTextValue("val_"+i).length() == 0) 
			continue;
		strTemp = "update e_sub_section set offered_to_college = "+WI.getStrValue(WI.fillTextValue("c_index"), null)+" , offered_to_dept = "+WI.getStrValue(WI.fillTextValue("d_index"), null)+
			" where sub_sec_index = "+WI.fillTextValue("val_"+i);
		dbOP.executeUpdateWithTrans(strTemp, null, null, false);
	}

}

AllProgramFix apf = new AllProgramFix();

	String strCollegeIndex = null;
	
	Vector vColleges = null;
	Vector vDept     = null;

if (WI.fillTextValue("showall").compareTo("1") == 0){
	if (WI.fillTextValue("page_action").length() == 0)
		vRetResult = apf.operateOnUpdateCollDeptOfferedTo(dbOP,request,4,WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	else{
		vRetResult = apf.operateOnUpdateCollDeptOfferedTo(dbOP,request,2,WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
		if (vRetResult == null)
			vRetResult = apf.operateOnUpdateCollDeptOfferedTo(dbOP,request,4,WI.fillTextValue("sy_from"),WI.fillTextValue("sy_to"),WI.fillTextValue("semester"));
	}
	if (vRetResult == null)
		strErrMsg = apf.getErrMsg();
	else	
		vColleges = (Vector)vRetResult.elementAt(0);
}



int iCount = 0;
%>


<form name="form_" action="./update_coll_dept_offer_to.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="6"><div align="center"><font color="#FFFFFF"><strong>:::: 
          COLLEGE/DEPARTMENT OFFERED TO INFORMATION ::::</strong></font></div></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" width="3%">&nbsp;</td>
      <td colspan="3"><font size="3"><b><%=WI.getStrValue(strErrMsg)%></b></font> </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td width="14%" height="25">SY / TERM</td>
      <td width="31%">
        <%
if(WI.fillTextValue("sy_from").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_from");
else
	strTemp = WI.fillTextValue("sy_from");
%>
        <input name="sy_from" type="text" class="textbox" id="sy_from"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=strTemp%>" size="4" maxlength="4"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;"
	  onKeyUp="DisplaySYTo('form_','sy_from','sy_to');">
        - 
        <%
if(WI.fillTextValue("sy_to").length() ==0)
	strTemp = (String)request.getSession(false).getAttribute("cur_sch_yr_to");
else
	strTemp = WI.fillTextValue("sy_to");
%>
        <input name="sy_to" type="text" class="textbox" id="sy_to"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
	  value="<%=strTemp%>" size="4" maxlength="4" readonly=""> 
        &nbsp;&nbsp; <select name="semester">
          <option value="1">1st</option>
          <%
strTemp = request.getParameter("semester");
if(strTemp == null) strTemp = "";

if(strTemp.compareTo("2") ==0)
{%>
          <option value="2" selected>2nd</option>
          <%}else{%>
          <option value="2">2nd</option>
          <%}if(strTemp.compareTo("3") ==0)
{%>
          <option value="3" selected>3rd</option>
          <%}else{%>
          <option value="3">3rd</option>
          <%}if(strTemp.compareTo("0") ==0)
{%>
          <option value="0" selected>Summer</option>
          <%}else{%>
          <option value="0">Summer</option>
          <%}%>
      </select></td>
      <td><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0"></a></td>
    </tr>
    <tr> 
      <td width="3%" height="25">&nbsp;</td>
      <td height="25">Filter Subject</td>
      <td><input name="sub_code" type="text" size="5" maxlength="5" class="textbox" value="<%=WI.fillTextValue("sub_code")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" > </td>
      <td width="52%">Filter Section (Starts With): 
	  
	  <input name="section_" type="text" size="10" class="textbox" value="<%=WI.fillTextValue("section_")%>"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" >
	  
	  
	  </td>
    </tr>
    <% 	if (WI.fillTextValue("reloadPage").compareTo("1") == 0) {%>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Select Subject </td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3"> <% strTemp =",sub_code from e_sub_section join subject on (e_sub_section.sub_index=subject.sub_index) " + 
				" where offering_sy_from = " + WI.fillTextValue("sy_from") + " and offering_sem = " + 
				WI.fillTextValue("semester") +" and offering_sy_to =" + WI.fillTextValue("sy_to") + 
				" and e_sub_section.is_del = 0 and is_child_offering = 0 and mix_sec_ref_index is null" +
				" and is_lec = 0";
				if (WI.fillTextValue("sub_code").length() > 0){
					strTemp += " and sub_code like '" + request.getParameter("sub_code")+"%'";
				}
				strTemp += " order by sub_code";
				
				%> <select name="sub_index" onChange="showList()" 
				style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	font-size: 12px; width:600px;">
          <option value="">Select Subject to check</option>
          <%=dbOP.loadCombo("distinct e_sub_section.sub_index","sub_code +'('+sub_name +')'",strTemp,WI.fillTextValue("sub_index"),false)%> </select> </td>
    </tr>
<%if(vColleges != null) {
strCollegeIndex = WI.fillTextValue("c_index");
//if(strCollegeIndex.length() == 0) 
//	strCollegeIndex = (String)vColleges.elementAt(0);
%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3">Apply To All :  
	  <select name="c_index" onChange="ChangeCollege()" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;">
      	  <option value="">General Offering</option>
		  <% for (int i = 0; i < vColleges.size(); i+=3){ 
				if (((String)vColleges.elementAt(i)).equals(strCollegeIndex) ){
					strCollegeIndex = (String)vColleges.elementAt(i);
					strTemp = " selected";
					vDept= (Vector)vColleges.elementAt(i+2);
				}
				else {	
					strTemp = "";
				}
	      %>
          <option value="<%=(String)vColleges.elementAt(i)%>" <%=strTemp%>><%=(String)vColleges.elementAt(i+1)%></option>
<%}//end for loop%>
        </select>
<%if(vDept != null) {%>
	  - 
	  <select name="d_index" style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	font-size: 10px;font-weight:bold">
	  	<option value="">ALL</option>
          <% for (int i = 0; i < vDept.size(); i+=2){ 
	  		if (((String)vDept.elementAt(i)).equals(WI.fillTextValue("d_index")) )
				strTemp = " selected";
			else
				strTemp = "";
	      %>
          <option value="<%=(String)vDept.elementAt(i)%>" <%=strTemp%>><%=(String)vDept.elementAt(i+1)%></option>
<%} //end for loop%>
        </select>
<%}%>
	  <a href="javascript:EditRecord('0')"><img src="../../../images/update.gif" width="60" height="26" border="0"></a></td>
    </tr>
<%}%>

    <%}%>
  </table>
 <% if (vRetResult!= null && vRetResult.size() > 0){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#DBB793"> 
      <td height="26" colspan="6" class="thinborder"><div align="center"><strong>LIST 
          OF SECTIONS OFFERED</strong></div></td>
    </tr>
    <tr>
      <td width="5%" class="thinborder">&nbsp;</td>
      <td width="22%" height="27" class="thinborder"><div align="center"><strong>SECTION</strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong>ENCODED BY 
          </strong></div></td>
      <td width="20%" class="thinborder"><div align="center"><strong>COLLEGE</strong></div></td>
      <td width="30%" class="thinborder"><div align="center"><strong>DEPARTMENT</strong></div></td>
      <td width="8%" class="thinborder">&nbsp;</td>
    </tr>
    <%	
	  int j = 0; 
	  int iTmpCollege = 0;
	  String strDeptIndex = null;
	  String strPageReloaded = WI.fillTextValue("page_reloaded");
	 for (int i =1,p = 0; i<vRetResult.size();i+=5,++p) {
		if (strPageReloaded.length() == 0) { 
			strCollegeIndex = (String)vRetResult.elementAt(i+3);
			strDeptIndex = (String)vRetResult.elementAt(i+4);
		}else{
			strCollegeIndex = WI.fillTextValue("c_index"+(String)vRetResult.elementAt(i));
			strDeptIndex = "";
		}
	 %>
    <tr>
      <td  class="thinborder"><%=p+1%></td>
      <td height="25"  class="thinborder"><input name="section<%=(String)vRetResult.elementAt(i)%>" type="text" class="textbox_noborder" value="<%=(String)vRetResult.elementAt(i+1)%>" size="16" readonly="yes"></td>
      <td class="thinborder"><div align="center"><%=(String)vRetResult.elementAt(i+2)%> </div></td>
      <td class="thinborder"> 
	  <select name="c_index<%=(String)vRetResult.elementAt(i)%>" onChange="ChangeCollege()">
	  <option value="">General Offering</option>
          <% for (j = 0; j < vColleges.size(); j+=3){ 
	  		if (strCollegeIndex != null && ((String)vColleges.elementAt(j)).compareTo(strCollegeIndex) == 0){
			vDept= (Vector)vColleges.elementAt(j+2);
	  %>
          <option value="<%=(String)vColleges.elementAt(j)%>" selected><%=(String)vColleges.elementAt(j+1)%></option>
          <%}else{%>
          <option value="<%=(String)vColleges.elementAt(j)%>"><%=(String)vColleges.elementAt(j+1)%></option>
          <%}
	  } //end for loop%>
        </select> </td>
      <td class="thinborder"> <select name="d_index<%=(String)vRetResult.elementAt(i)%>" 
	  style="font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;	font-size: 10px;font-weight:bold">
	  	<option value=""></option>
          <% for (j = 0; vDept != null && j < vDept.size(); j+=2){ 
	  		if (strDeptIndex != null && ((String)vDept.elementAt(j)).compareTo(strDeptIndex) == 0){
	  %>
          <option value="<%=(String)vDept.elementAt(j)%>" selected><%=(String)vDept.elementAt(j+1)%></option>
          <%}else{%>
          <option value="<%=(String)vDept.elementAt(j)%>"><%=(String)vDept.elementAt(j+1)%></option>
          <%}
	  } //end for loop%>
        </select> &nbsp; </td>
      <td class="thinborder"><a href="javascript:EditRecord(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../../images/update.gif" width="60" height="26" border="0"></a></td>
	  <input type="hidden" name="val_<%=iCount++%>" value="<%=(String)vRetResult.elementAt(i)%>">
    </tr>
    <%}//end for loop%>
  </table>
 <%} // vRetResult%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#A49A6A"> 
      <td height="25" bgcolor="#FFFFFF">&nbsp;</td>
    </tr>
    <tr bgcolor="#A49A6A">
      <td height="25"bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
 <input type="hidden" name="info_index">
 <input type="hidden" name="reloadPage">
 <input type="hidden" name="showall">
 <input type="hidden" name="page_action">
 <input type="hidden" name="page_reloaded">
 <input type="hidden" name="update_all">
 
 <input type="hidden" name="max_disp" value="<%=iCount%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
