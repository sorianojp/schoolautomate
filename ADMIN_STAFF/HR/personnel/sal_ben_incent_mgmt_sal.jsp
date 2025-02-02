<%@ page language="java" import="utility.*,java.util.Vector,hr.HRSalaryGrade"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.

boolean bolIsSchool = false;
if ((new CommonUtil().getIsSchool(null)).equals("1")){
	bolIsSchool = true;
}

%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style> 
	.fontsize{
		font-size:11px;
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function PageAction(strInfoIndex,strAction) {
	document.form_.page_action.value = strAction;
	if(strAction == "1") {
		document.form_.hide_save.src = "../../../images/blank.gif";
	}
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;
	this.SubmitOnce("form_");
}
function ReloadPage() {
	document.form_.page_action.value = "";
	this.SubmitOnce("form_");
}
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function PrepareToEdit(index){
	document.form_.prepareToEdit.value = "1";
	document.form_.info_index.value = index;
	document.form_.consider_vedit.value = "1";//take edit info.
	this.SubmitOnce("form_");
}
function FocusRank(){
	document.form_.sal_grade_index.focus();
}
</script>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strImgFileExt = null;
	String strPrepareToEdit = WI.getStrValue(WI.fillTextValue("prepareToEdit"),"0");
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-salary grade","sal_ben_incent_mgmt_sal.jsp");

/**		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}**/
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
int iAccessLevel = -1;
														
if (!strSchCode.startsWith("AUF")){
	iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,
												(String)request.getSession(false).getAttribute("userId"),
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"sal_ben_incent_mgmt_sal.jsp");
}else{
    iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"Payroll","CONFIGURATION",request.getRemoteAddr(),
														"sal_ben_incent_mgmt_sal.jsp");
}	

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
Vector vEditInfo  = null;
HRSalaryGrade hrSG = new HRSalaryGrade();

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {//add,edit,delete
	if(hrSG.operateOnSG(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = hrSG.getErrMsg();
	else {	
		strErrMsg = "Operation is successful.";
		strPrepareToEdit = "0";
	}
}
//System.out.println("Before 1 : "+strErrMsg);
if(strPrepareToEdit.compareTo("1") == 0) {
	vEditInfo = hrSG.operateOnSG(dbOP, request,3);
	if(vEditInfo == null)
		strErrMsg = hrSG.getErrMsg();
}//System.out.println("Before 2 : "+strErrMsg);
//get the list. 
int iAction = 4;//view all. 
if(WI.fillTextValue("view_prev_grade").compareTo("1") == 0)
	iAction = 5;
vRetResult = hrSG.operateOnSG(dbOP, request, iAction);
%>

<body bgcolor="#663300" onLoad="FocusRank();" class="bgDynamic">
<form action="./sal_ben_incent_mgmt_sal.jsp" method="post" name="form_">
  <table width="100%"  bgcolor="#FFFFFF"cellpadding="0" cellspacing="0">
    <tr bgcolor="#999966" class="footerDynamic"> 
      <td height="25" colspan="5"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          SALARY MANAGEMENT PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" align="right">
	  <a href="./sal_ben_incent_mgmt_main.jsp">
	  <img src="../../../images/go_back.gif" width="50" height="27" border="0"></a></td>
      <td width="3%" rowspan="14" align="center" valign="middle"><img src="../../../images/sidebar.gif" width="11" height="270"></td>
    </tr>
    <tr> 
      <td width="2%" height="25">&nbsp;</td>
      <td colspan="3"><font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td width="22%" height="25" class="fontsize">Job Grade/Academic Rank</td>
      <td width="26%"> <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(7);
else	
	strTemp = WI.fillTextValue("sal_grade_index");
%> <select name="sal_grade_index">
          <option value="">Select A Salary Grade</option>
          <%=dbOP.loadCombo("SAL_GRADE_INDEX","GRADE_NAME"," FROM HR_PRELOAD_SAL_GRADE order by grade_name",strTemp,false)%> </select>	</td>
      <td>
<%if(iAccessLevel > 1) {%>
	  <a href='javascript:viewList("HR_PRELOAD_SAL_GRADE","SAL_GRADE_INDEX","GRADE_NAME","SALARY GRADE",
				"HR_SALARY_GRADE,HR_INFO_SERVICE_RCD","SAL_GRADE_INDEX, SAL_GRADE_INDEX", 
				" and HR_SALARY_GRADE.is_del = 0, and HR_INFO_SERVICE_RCD.is_del = 0","","sal_grade_index")'><img src="../../../images/update.gif" border="0"></a>
<%}%>
				</td>
    </tr>
<% if (bolIsSchool){%> 
    <tr> 
      <td height="18">&nbsp;</td>
      <td height="18" class="fontsize">Employment Category</td>
      <td height="30" colspan="2"> <%
if(WI.fillTextValue("consider_vedit").equals("1") && vEditInfo != null)
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(7));
else	
	strTemp = WI.fillTextValue("teaching_staff");
%> <select name="teaching_staff" onChange="ReloadPage()">
		 <option value="">-</option>
<%if (strTemp.equals("0")){ %>  
          <option value="0" selected="selected"> Teaching Staff</option>
<%}else{%>
          <option value="0"> Teaching Staff</option>
<%}if (strTemp.equals("1")) {%> 
          <option value="1" selected="selected"> Non - Teaching Staff</option>
<%}else{%>
          <option value="1"> Non - Teaching Staff</option>
<%}%> 
        </select> </td>
    </tr>
<%}else{%> 
		<input type="hidden" value="1"  name="teaching_staff">
<%}%>
    <tr> 
      <td height="29">&nbsp;</td>
      <td height="29" class="fontsize">Salary Rate/Range</td>
      <td colspan="2"> <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("sal_range_fr");
%> <input name="sal_range_fr" type="text" size="15" value="<%=strTemp%>"
	  class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','sal_range_fr')">
        to 
        <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("sal_range_to");
%> <input name="sal_range_to" type="text" size="15" value="<%=WI.getStrValue(strTemp)%>"
	  class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeyUp="AllowOnlyFloat('form_','sal_range_to')"> </td>
    </tr>
    <tr> 
      <td height="10">&nbsp;</td>
      <td height="10" valign="top">&nbsp;</td>
      <td height="10" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" valign="top" class="fontsize">Scale/Grade Description</td>
      <td colspan="2"> <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("description");
%> <textarea name="description" cols="60" rows="3"
	  class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" 
	  onblur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp)%></textarea></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td height="18" valign="top">&nbsp;</td>
      <td colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" colspan="3" class="fontsize">Effective Date&nbsp;&nbsp;:&nbsp;&nbsp;&nbsp;&nbsp; 
        From 
        <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.fillTextValue("eff_date_fr");
%> <input name="eff_date_fr" type= "text" value="<%=strTemp%>" class="textbox" size="10"  
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('form_','eff_date_fr','/')"> 
        <a href="javascript:show_calendar('form_.eff_date_fr');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        &nbsp;&nbsp;To 
        <%
if(WI.fillTextValue("consider_vedit").compareTo("1") == 0 && vEditInfo != null)
	strTemp = (String)vEditInfo.elementAt(6);
else	
	strTemp = WI.fillTextValue("eff_date_to");
%> <input name="eff_date_to" type= "text" value="<%=WI.getStrValue(strTemp)%>" class="textbox" size="10"  
		onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyIntegerExtn('form_','eff_date_to','/')"> 
        <a href="javascript:show_calendar('form_.eff_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
        (leave date to blank if salary grade is active)</td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td height="18" valign="top">&nbsp;</td>
      <td height="18" colspan="2">&nbsp;</td>
    </tr>
    <tr> 
      <td height="25">&nbsp;</td>
      <td height="25" valign="top">&nbsp;</td>
      <td colspan="2" align="center"> <% if (iAccessLevel > 1){
	if (strPrepareToEdit.compareTo("1") != 0){%> 
        <a href='javascript:PageAction("","1");'><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
        <font size="1">click to save entries</font> <%}else{ %> <a href='javascript:PageAction("","2");'><img src="../../../images/edit.gif" border="0"></a> 
        <font size="1">click to save changes</font> <%}
}%> <a href="./sal_ben_incent_mgmt_sal.jsp"><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
        to cancel and clear entries</font> </td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td height="18" valign="top">&nbsp;</td>
      <td height="18" colspan="2">&nbsp;</td>
    </tr>
  </table>
  <table width="100%"  bgcolor="#FFFFFF"cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="4" bgcolor="#666666"><div align="center"><font color="#FFFFFF"><strong>LIST 
          OF JOB GRADE/ACADEMIC RANK( 
          <%
strTemp =WI.fillTextValue("view_prev_grade");
if(strTemp.compareTo("1") == 0)
	strTemp = "checked";
else
	strTemp = "";
%>
          <input type="checkbox" name="view_prev_grade" value="1" <%=strTemp%> onClick="ReloadPage();">
          <font size="1">CLICK TO VIEW JOB GRADE / ACADEMIC RANK HISTORY</font>)</strong></font></div></td>
    </tr>
  </table>
<%
if(vRetResult != null && vRetResult.size() > 0){%>	  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#808080">
    <tr bgcolor="#FFFFFF"> 
      <td width="23%" height="26" class="thinborder"><div align="center"><strong>JOB 
          GRADE <% if (bolIsSchool){%>/ <br>
          ACADEMIC RANK<%}%></strong><font color="#000000" size="1"></font></div></td>
      <td width="23%" class="thinborder"><div align="center"><strong>SALARY RATE/RANGE</strong></div></td>
      <td width="25%" class="thinborder"><div align="center"><strong>SCALE/GRADE DESCRIPTION</strong></div></td>
      <td width="15%" class="thinborder"><div align="center"><strong>EFFECTIVE DATE</strong></div></td>
      <td width="7%" align="center" class="thinborder"><strong>EDIT</strong></td>
      <td width="7%" align="center" class="thinborder"><strong>DELETE</strong></td>
    </tr>
<%
for(int i = 0 ; i < vRetResult.size() ; i += 8){%>
    <tr bgcolor="#FFFFFF"> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i + 1)%></td>
      <td height="25" align="right" class="thinborder"><%=CommonUtil.formatFloat((String)vRetResult.elementAt(i + 2),true)%>
	  <%=WI.getStrValue((String)vRetResult.elementAt(i + 3)," - " ,"","")%>&nbsp;</td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(vRetResult.elementAt(i + 4),"&nbsp;")%></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i + 5)%><%=WI.getStrValue((String)vRetResult.elementAt(i + 6)," to ","","")%></td>
      <td height="25" class="thinborder">&nbsp;
	  <%if(iAccessLevel > 1){%>
	  <a href='javascript:PrepareToEdit("<%=(String)vRetResult.elementAt(i)%>");'><img src="../../../images/edit.gif" border="0"></a>
	  <%}%></td>
      <td class="thinborder">&nbsp;
	  <%if(iAccessLevel == 2){%>
	  <a href='javascript:PageAction("<%=(String)vRetResult.elementAt(i)%>","0");'><img src="../../../images/delete.gif" border="0"></a>
	  <%}%></td>
    </tr>
<%}%>

  </table>
 <%}//only if vRetResult.size() > 0%>
   <table width="100%"  bgcolor="#FFFFFF"cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25">&nbsp;</td>
    </tr>
    <tr bgcolor="#999966" class="footerDynamic"> 
      <td height="25">&nbsp;</td>
    </tr>
</table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="consider_vedit" value="0"><!-- consider vEdit -->



</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
