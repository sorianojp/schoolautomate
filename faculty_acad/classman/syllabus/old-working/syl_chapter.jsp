<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style>

.trigger{
	cursor: pointer;
	cursor: hand;
}
.branch{
	display: none;
	margin-left: 16px;
}
</style>
</head>
<script language="javascript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
/////////for collapse.
var openImg = new Image();
openImg.src = "../../../images/box_with_minus.gif";
var closedImg = new Image();
closedImg.src = "../../../images/box_with_plus.gif";

function showBranch(branch){
	var objBranch = document.getElementById(branch).style;
	if(objBranch.display=="block")
		objBranch.display="none";
	else
		objBranch.display="block";
}

function swapFolder(img){
	objImg = document.getElementById(img);
	if(objImg.src.indexOf('box_with_plus.gif')>-1)
		objImg.src = openImg.src;
	else
		objImg.src = closedImg.src;
}
//////////end of collapse.



	var childWnd = null;
	function  CheckFocus() {
		if(childWnd != null) {
			//alert("Popup is open");
			childWnd.focus();
			return null;
		}
	}


function PageAction(strAction) {
	//called for clear 
	if(strAction == '-1') {
		document.form_.chapter_name.value = "";
		document.form_.hours.value = "";
		document.form_.description.value = "";
		document.form_.exam_name.value = "";
		
		return;
	}
	document.form_.page_action.value = strAction;
	if(strAction == '')
		document.form_.preparedToEdit.value = "";
}
function PreparedToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.preparedToEdit.value = "1";
}
function AddSub(strInfoIndex) {
	var strPgLoc = "./syl_chapter_sub.jsp?chapter_index="+strInfoIndex;
	//open window to add sub chapter.
	childWnd = window.open(strPgLoc,"myfile",'dependent=no,width=700,height=500,top=100,left=100,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	childWnd.focus();

}
</script>


<%@ page language="java" import="utility.*,java.util.Vector,ClassMgmt.CMSyllabus" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	Vector vRetResult = null;
	
	//authenticate this user.
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FACULTY/ACAD. ADMIN-CLASS MANAGEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("FACULTY/ACAD. ADMIN"),"0"));
		}
	}
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../faculty_acad/faculty_acad_bottom_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out.Please login again.");
		response.sendRedirect("../../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}

	//end of authenticaion code.

	try {
		dbOP = new DBOperation();
	}
	catch(Exception exp) {
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"><%=strErrMsg%></p>
		<%
		return;
	}

CMSyllabus cms = new CMSyllabus();
boolean bolRetainVal = false;
String strPreparedToEdit = WI.getStrValue(WI.fillTextValue("preparedToEdit"), "0");

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(cms.operateOnChapter(dbOP, request, Integer.parseInt(strTemp)) == null) {
		bolRetainVal = true;//retain prev value, do not get from vEditInfo.
		strErrMsg = cms.getErrMsg();
	}
	else {
		strErrMsg = "Operation successful.";
		strPreparedToEdit = "0";
	}
}
	vRetResult = cms.operateOnChapter(dbOP, request, 4);
	if(vRetResult == null && strErrMsg == null) 
		strErrMsg = cms.getErrMsg();

Vector vEditInfo = null;
if(strPreparedToEdit.equals("1"))
	vEditInfo = cms.operateOnChapter(dbOP, request, 3);


Vector vChapterSubChapInfo = null;
if(vRetResult != null)
	vChapterSubChapInfo = cms.operateOnChapter(dbOP, request, 5);


%>
<body bgcolor="#93B5BB" onFocus="CheckFocus();">
<form name="form_" method="post" action="./syl_chapter.jsp" onSubmit="SubmitOnceButton(this);">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr bgcolor="#6A99A2">
      <td width="786" height="25"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>::::
          COURSE OUTLINE MAINTENANCE PAGE::::</strong></font></div></td>
    </tr>
    <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;
	  <a href="./syllabus.jsp?sub_index=<%=WI.fillTextValue("sub_index")%>"><img src="../../../images/go_back.gif" border="0"></a>
	  &nbsp;&nbsp;&nbsp;<font style="font-size:14px; color:#FF0000;"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="5" cellspacing="0">
    <tr>
      <td colspan="2">
	  <div class="trigger" onClick="showBranch('branch1');swapFolder('folder1')" style="font-size:11px; color:#0000FF; font-weight:bold"> 
	  <img src="../../../images/box_with_plus.gif" border="0" id="folder1"> 
	  View detail of chapter-sub chapter created ::: 
	  <input type="image" src="../../../images/refresh.gif"></div></td>
    </tr>
    <tr>
      <td colspan="2">&nbsp;
	  <%if(vChapterSubChapInfo != null) {
	    Vector vChapterInfo = (Vector)vChapterSubChapInfo.remove(0);%>
	<span class="branch" id="branch1">	  	
		<table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
			<%for(int i = 0; i < vChapterInfo.size(); i += 6){%>
				<tr valign="top">
					<td class="thinborder">
						<%=vChapterInfo.elementAt(i + 5)%>.<%=vChapterInfo.elementAt(i + 1)%>
					</td>
					<td class="thinborder">
						<%=ConversionTable.replaceString(WI.getStrValue(vChapterInfo.elementAt(i + 2),"&nbsp;"), "\r\n","<br>")%>
					</td>
					<td class="thinborder">
						<%=vChapterInfo.elementAt(i + 3)%>hrs
					</td>
				</tr>
				<%for(int j = 0; j < vChapterSubChapInfo.size();){
					if(!vChapterInfo.elementAt(i).equals(vChapterSubChapInfo.elementAt(0)))
						break;
				%>
					<tr valign="top" style="font-size:9px; color:#0000FF;">
						<td class="thinborder">
							&nbsp;&nbsp;<%=vChapterInfo.elementAt(i + 5)%>.<%=vChapterSubChapInfo.elementAt(5)%>.<%=vChapterSubChapInfo.elementAt(2)%>
						</td>
						<td class="thinborder">
							<%=ConversionTable.replaceString(WI.getStrValue(vChapterSubChapInfo.elementAt(3),"&nbsp;"), "\r\n","<br>")%>
						</td>
						<td class="thinborder">
							<%=vChapterSubChapInfo.elementAt(4)%>hrs
						</td>
					</tr>
				<%vChapterSubChapInfo.removeElementAt(0);vChapterSubChapInfo.removeElementAt(0);
				  vChapterSubChapInfo.removeElementAt(0);vChapterSubChapInfo.removeElementAt(0);
				  vChapterSubChapInfo.removeElementAt(0);vChapterSubChapInfo.removeElementAt(0);
				}//end of showing sub chapter.
				//show exam name if there is any.. 
				if(vChapterInfo.elementAt(i + 4) != null) {%>
					<tr valign="top" style="font-size:9px; font-weight:bold">
						<td colspan="3" class="thinborder" align="center">
							<%=((String)vChapterInfo.elementAt(i + 4)).toUpperCase()%>
						</td>
					</tr>
				<%}//show only if exam name is there.. %>
				
			<%}//end of for loop.for(int i = 0; i < vChapterInfo.size(); i += 6)%>
		</table>
	  </span>
	  <%}%>
	  </td>
    </tr>
    <tr>			
      <td>Chapter # </td>
      <td>
	  <select name="order_no">
<%
if(vEditInfo != null && !bolRetainVal)
	strTemp = (String)vEditInfo.elementAt(5);
else	
	strTemp = WI.getStrValue(WI.fillTextValue("order_no"), "1");
int iOrderNo = Integer.parseInt(strTemp);
for(int i = 1; i < 100; ++i) {
	if(iOrderNo == i)
		strTemp = " selected";
	else	
		strTemp = "";
%>	
		<option value="<%=i%>"<%=strTemp%>><%=i%></option>	  
<%}%>
	  </select>	  </td>
    </tr>
    <tr>
      <td width="17%">Chapter Title </td>
      <td width="83%">
<%
if(vEditInfo != null && !bolRetainVal)
	strTemp = (String)vEditInfo.elementAt(1);
else	
	strTemp = WI.fillTextValue("chapter_name");
%>
	  <input name="chapter_name" type="text" size="67" maxlength="256" class="textbox" value="<%=strTemp%>"
	   onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px;"></td></tr>
    <tr>
      <td valign="top">Duration(hrs)</td>
      <td>
<%
if(vEditInfo != null && !bolRetainVal)
	strTemp = (String)vEditInfo.elementAt(3);
else	
	strTemp = WI.fillTextValue("hours");
%>
	  <input name="hours" type="text" size="4" maxlength="4" class="textbox" value="<%=strTemp%>"
	   onFocus="style.backgroundColor='#D3EBFF'" onBlur="AllowOnlyFloat('form_','hours');style.backgroundColor='white'" style="font-size:11px;"
	   onKeyUp="AllowOnlyFloat('form_','hours');"> 
      (no of hours) </td>
    </tr>
    <tr>
      <td valign="top">Topic</td>
      <td>
<%
if(vEditInfo != null && !bolRetainVal)
	strTemp = (String)vEditInfo.elementAt(2);
else	
	strTemp = WI.fillTextValue("description");
%>
	   <textarea name="description" cols="70" rows="8" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" class="textbox" style="font-size:11px;"><%=WI.getStrValue(strTemp)%></textarea></td>
    </tr>
    <tr>
      <td valign="top">Exam Name </td>
      <td>
<%
if(vEditInfo != null && !bolRetainVal)
	strTemp = (String)vEditInfo.elementAt(4);
else	
	strTemp = WI.fillTextValue("exam_name");
%>
	  <input name="exam_name" type="text" size="16" maxlength="16" class="textbox" value="<%=WI.getStrValue(strTemp)%>"
	   onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" style="font-size:11px;"> 
      (If there is exam after this chapter) </td>
    </tr>
    <tr>
      <td colspan="2"> <div align="center">
          <%
 	strTemp = strPreparedToEdit;
    if(WI.getStrValue(strTemp,"0").compareTo("0") == 0) {
		if (iAccessLevel > 1){
%>
          <input type="submit" value="Save Information" style="font-size:11px; height:28px;border: 1px solid #FF0000;"
	  onClick="PageAction('1');">
	  &nbsp;&nbsp;
	  <input type="button" value="Clear fields " style="font-size:11px; height:28px;border: 1px solid #FF0000;"
	  onClick="PageAction('-1');">
          <%     }
  }else{ %>
          <input type="submit" value="Edit Information" style="font-size:11px; height:28px;border: 1px solid #FF0000;"
	  onClick="PageAction('2');">
      &nbsp;&nbsp;    
	  <input type="submit" value="Cancel Edit" style="font-size:11px; height:28px;border: 1px solid #FF0000;"
	  onClick="PageAction('');">
          
  <%}%>
          &nbsp;</div></td>
    </tr>
    <tr>
      <td colspan="2"><hr size="1" noshade></td>
    </tr>
  </table>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#BDD5DF">
      <td width="100%" height="25" colspan="7" class="thinborder" align="center"><strong>COURSE OUTLINE</strong></td>
    </tr>
    <tr>
      <td height="25" class="thinborder" style="font-size:9px" width="20%"><strong>CHAPTER</strong></td>
      <td class="thinborder" style="font-size:9px" width="8%"><strong>HOURS</strong></td>
      <td class="thinborder" style="font-size:9px" width="42%"><strong>TOPIC</strong></td>
      <td class="thinborder" style="font-size:9px" width="9%"><strong>EXAM NAME </strong></td>
      <td class="thinborder" style="font-size:9px" width="7%"><strong>EDIT</strong></td>
      <td class="thinborder" style="font-size:9px" width="7%"><strong>REMOVE</strong></td>
      <td class="thinborder" style="font-size:9px" width="7%"><strong>ADD SUB CHAPTER </strong></td>
    </tr>
<%for(int i =0; i < vRetResult.size(); i += 6){%>
    <tr>
      <td height="25" class="thinborder" style="font-size:9px" width="20%">&nbsp;<%=(String)vRetResult.elementAt(i + 5)%>.<%=(String)vRetResult.elementAt(i + 1)%></td>
      <td class="thinborder" style="font-size:9px"><%=(String)vRetResult.elementAt(i + 3)%></td>
      <td class="thinborder" style="font-size:9px"><span class="thinborder" style="font-size:9px">
	  <%=ConversionTable.replaceString(WI.getStrValue(vRetResult.elementAt(i + 2), "&nbsp;"), "\r\n","<br>")%></span></td>
      <td class="thinborder" style="font-size:9px"><span class="thinborder" style="font-size:9px">&nbsp;
	  <%=WI.getStrValue(vRetResult.elementAt(i + 4))%></span></td>
      <td class="thinborder" style="font-size:9px">
	  <input name="submit" type="submit" style="font-size:11px; height:28px;border: 1px solid #FF0000;"
	  onClick="PreparedToEdit('<%=vRetResult.elementAt(i)%>');" value="&nbsp;Edit&nbsp;"></td>
      <td class="thinborder" style="font-size:9px"><span class="thinborder" style="font-size:9px">
        <input name="submit2" type="submit" style="font-size:11px; height:28px;border: 1px solid #FF0000;"
	  onClick="PageAction('0');" value="Delete">
      </span></td>
      <td class="thinborder" style="font-size:9px"><span class="thinborder" style="font-size:9px">
        <input name="submit22" type="button" style="font-size:11px; height:28px;border: 1px solid #FF0000;"
	  onClick="AddSub('<%=vRetResult.elementAt(i)%>');" value="Add Sub">
      </span></td>
    </tr>
<%}%>
  </table>
<%}%>
  <table width="100%" border="0" cellpadding="2" cellspacing="0">
  <tr bgcolor="#FFFFFF">
      <td height="25">&nbsp;</td>
  </tr>
  <tr bgcolor="#6A99A2">
    <td height="25">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="reload_page">
<input type="hidden" name="page_action">
<input type="hidden" name="sub_index" value="<%=WI.fillTextValue("sub_index")%>">
<input type="hidden" name="preparedToEdit" value="<%=strPreparedToEdit%>">

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
