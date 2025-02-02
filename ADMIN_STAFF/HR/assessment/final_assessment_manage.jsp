<%@ page language="java" import="utility.*,java.util.Vector,hr.HREvaluationSheet" %>
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
function ReloadPage()
{
	document.staff_profile.page_action.value = "";
	this.SubmitOnce('staff_profile');
}
function AddRecord(){
	document.staff_profile.page_action.value ="1";
	this.SubmitOnce('staff_profile');
}
function DeleteRecord(){
	document.staff_profile.page_action.value ="0";
	this.SubmitOnce('staff_profile');
}
function FocusID() {
	document.staff_profile.emp_id.focus();
}
function ResetPage() {
	//document.staff_profile.sy_from.value = "";
	this.ReloadPage();
}
</script>
<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	String strRootPath = null;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-HR-Assessment and Evaluation","hr_assessment.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		strRootPath = readPropFile.getImageFileExtn("installDir");
		
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
		if(strRootPath == null || strRootPath.trim().length() ==0)
		{
			strErrMsg = "Installation directory path is not set. Please check the property file for installDir KEY.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in connection. Please try again.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","ASSESSMENT AND EVALUATION",request.getRemoteAddr(),
														"hr_assessment.jsp");
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

//end authorization
Vector vEmpRec = null;
Vector vYearInfo = null;
Vector vEvalPeriod = null;
Vector vEditInfo   = null;
Vector vTemp = null;

String strInfoIndex = null;


HREvaluationSheet hrES = new HREvaluationSheet();
String strPageAction = WI.fillTextValue("page_action");
if(WI.fillTextValue("criteria_index").length() > 0) {
	vYearInfo = hrES.getEvalSheetYearInfo(dbOP, WI.fillTextValue("criteria_index"));
	if(vYearInfo == null) {
		strErrMsg = hrES.getErrMsg();
	}
}
if(WI.fillTextValue("sy_from").length() > 0) {
	vEvalPeriod = hrES.operateOnEvalPeriod(dbOP, request, 4);
}

enrollment.Authentication authentication = new enrollment.Authentication();
if(WI.fillTextValue("sy_from").length() > 0 && WI.fillTextValue("criteria_index").length() > 0) {
	vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	if(vEmpRec == null || vEmpRec.size() ==0) {
		strErrMsg = authentication.getErrMsg();
	}
}

if(WI.fillTextValue("page_action").length() > 0) {
	if(hrES.operateOnFinalEval(dbOP, request,Integer.parseInt(WI.fillTextValue("page_action"))) == null)
		strErrMsg = hrES.getErrMsg();
	else {
		strErrMsg = "Operation Successful.";
	}		
}
//get info here if exists.
if(vEmpRec != null && vEvalPeriod != null) {
	vEditInfo = hrES.operateOnFinalEval(dbOP, request, 3);
	if(vEditInfo != null)
		strInfoIndex = (String)vEditInfo.elementAt(9);
}	
%>
<form action="" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td height="25" colspan="3" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
        EVALUATION RECORD PAGE ::::</strong></font></div></td>
    </tr>
    <tr>
      <td width="4%" height="25">&nbsp;</td>
      <td width="17%" height="25">&nbsp;</td>
      <td width="79%">&nbsp;</td>
    </tr>
    <%
if(strErrMsg != null){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="2"><font size="3"><b><%=strErrMsg%></b></font></td>
    </tr>
    <%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Evaluation Criteria</td>
      <td><select name="criteria_index" onChange="ResetPage();">
          <option value="" selected>Select Evaluation Criteria</option>
          <%=dbOP.loadCombo("CRITERIA_INDEX","CRITERIA_NAME"," FROM HR_EVAL_CRITERIA",WI.fillTextValue("criteria_index"),false)%>
        </select>
          <%strTemp = null;strErrMsg = null;
			for(int i =0; vYearInfo != null && i < vYearInfo.size(); i += 3) {
				if(((String)vYearInfo.elementAt(i + 2)).compareTo("1") == 0){
					strTemp = (String)vYearInfo.elementAt(i);
					strErrMsg = (String)vYearInfo.elementAt(i + 1);
				}
			}
			if(strTemp == null && vYearInfo != null) {
				strTemp = (String)vYearInfo.elementAt(0);
				strErrMsg = (String)vYearInfo.elementAt(1);
			}
			%>
          <strong><font size="3"><%=WI.getStrValue(strTemp,""," - "+strErrMsg+"</font></strong><font size=1>, (Active evaluation period)","")%></font></strong>
          <input type="hidden" name="sy_from" value="<%=WI.getStrValue(strTemp)%>">
          <input type="hidden" name="sy_to" value="<%=WI.getStrValue(strErrMsg)%>">
      </td>
    </tr>
    <%if(vEvalPeriod != null && vEvalPeriod.size() > 0){%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Employee ID : </td>
      <td><input value ="<%=WI.fillTextValue("emp_id")%>" name="emp_id" type="text"  class="textbox" id="emp_id"  
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16" maxlength="32"  ></td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Evaluation Period</td>
      <td><select name="eval_period_index">
          <%
	  strTemp = WI.fillTextValue("eval_period_index");	
	  for(int i = 0; vEvalPeriod != null && i < vEvalPeriod.size(); i += 3) {
	  	if(strTemp.compareTo((String)vEvalPeriod.elementAt(i)) == 0){%>
          <option value="<%=(String)vEvalPeriod.elementAt(i)%>" selected><%=(String)vEvalPeriod.elementAt(i + 1)%> - <%=(String)vEvalPeriod.elementAt(i + 2)%></option>
          <%}else{%>
          <option value="<%=(String)vEvalPeriod.elementAt(i)%>"><%=(String)vEvalPeriod.elementAt(i + 1)%> - <%=(String)vEvalPeriod.elementAt(i + 2)%></option>
          <%}
	  }%>
        </select>
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Evaluator ID</td>
      <td><%
	  strTemp = WI.fillTextValue("evaluator_id");
	  if(strTemp.length() == 0) 
	  	strTemp = (String)request.getSession(false).getAttribute("userId");
		%>
          <input value="<%=strTemp%>" name="evaluator_id" class="textbox" type="text" 
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="16">
      </td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">Detailed Evaluation</td>
      <td>&nbsp;
          <%vTemp = hrES.getSummaryOfDetailedEval(dbOP, request);
	  if(vTemp != null) {%>
        Total Evaluations : <%=(String)vTemp.elementAt(0)%>, Average Rank Point : <%=(String)vTemp.elementAt(1)%>, 
        Total Evaluator : <%=(String)vTemp.elementAt(2)%>
              <%}else{%>
              <font size="3"><b>No information found.</b></font>
              <%}%>
      </td>
    </tr>
    <%}//only if vEvalPeriod is not null.%>
    <tr>
      <td height="25">&nbsp;</td>
      <td height="25">&nbsp;</td>
      <td><a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" width="81" height="21" border="0"></a></td>
    </tr>
  </table>
  <%
if(vEmpRec != null && vEmpRec.size() > 0) {%>
<table width="100%" border="0" cellspacing="0" cellpadding="5" bgcolor="#FFFFFF">
    <tr> 
      <td><hr size="1">
	  <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
        <table width="400" border="0" align="center">
          <tr> 
            <td width="100%" valign="middle"> <%strTemp = "<img src=\"../../../upload_img/"+WI.fillTextValue("emp_id").toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\">";%> <%=WI.getStrValue(strTemp)%> <br> <br> <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}%> <br> <strong><%=WI.getStrValue(strTemp)%></strong><br> <font size="1"><%=WI.getStrValue(strTemp2)%></font><br> <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> </td>
          </tr>
        </table>
        <br> 
		 <%
		 if( (WI.fillTextValue("eval_period_index").length() > 0 && WI.fillTextValue("criteria_index").length() > 0)
		 	 || vEditInfo != null) {%>
		 <table width="90%" border="0" align="center" cellpadding="5" cellspacing="3">
          <tr>
            <td>Final Rating : 
              <%
			  if(vEditInfo != null) 
			  	strTemp = (String)vEditInfo.elementAt(6);
			  else	
			  	strTemp = WI.fillTextValue("final_rating");
			  %>
			  <input value="<%=strTemp%>" name="final_rating" type= "text" class="textbox"  
			  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
			  size="4" maxlength="3" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
            &nbsp;&nbsp;&nbsp;&nbsp;
			<%if(vEditInfo != null) {
				if(vEditInfo.elementAt(10) == null) {%>
				Rank Information not found.
				<%}else{%>
				<font size="3">RANK ::: <%=vEditInfo.elementAt(10)%></font>
			    <%}
				}%>
			</td>
          </tr>
          <tr> 
            <td><strong><font color="#FF0000">SUGGESTIONS</font></strong><br> 
            <%
			  if(vEditInfo != null) 
			  	strTemp = (String)vEditInfo.elementAt(8);
			  else	
			  	strTemp = WI.fillTextValue("suggestions");
			  %>
			    <textarea name="suggestions" cols="70" rows="4" class="textbox" 
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea></td>
          </tr>
          <tr> 
            <td><strong><font color="#FF0000">COMMENTS</font></strong><br> 
			<%
			  if(vEditInfo != null) 
			  	strTemp = (String)vEditInfo.elementAt(7);
			  else	
			  	strTemp = WI.fillTextValue("comments");
			  %><textarea name="comments" cols="70" rows="4" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
				onBlur="style.backgroundColor='white'" ><%=strTemp%></textarea> 
            </td>
          </tr>
          <tr> 
            <td>
			<div align="center"><font size="1"> 
			<%
			if(iAccessLevel > 1) {
			if(strInfoIndex == null){%>
                <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0"></a>click to save entries
			<%}else{%>
			    <a href="javascript:AddRecord();"><img src="../../../images/edit.gif" border="0"></a>click to modify entries
			    <%if(iAccessLevel == 2) {%>
				<a href="javascript:DeleteRecord();"><img src="../../../images/delete.gif" border="0"></a>
				click to remove entries
			<%		}//only if iAccessLevel == 2
				}//only if strInfoIndex != null
			}//only if iAccesslevel > 1%>
                </font></div>
			
			</td>
          </tr>
        </table>
        <%}//only if(WI.fillTextValue("eval_period_index").length() > 0 || vEditInfo != null) { %>
      </td>
    </tr>
  </table>
<%} // vEmpRecord != null;%>
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="page_action">
<input type="hidden" name="info_index" value="<%=WI.getStrValue(strInfoIndex)%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
