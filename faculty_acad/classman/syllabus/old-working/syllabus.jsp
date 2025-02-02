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
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Faculty/Acad. Admin-CLASS MANAGEMENT-Syllabus","syllabus.jsp");
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
strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(cms.operateOnMain(dbOP, request, Integer.parseInt(strTemp)) == null)
		strErrMsg = cms.getErrMsg();
	else
		strErrMsg = "Operation successful.";
}
Vector vSYLMain = null;
Vector vChapterSubChapInfo = null;
Vector vRef = null;

if(request.getParameter("sub_index") != null) {
	vRetResult = cms.operateOnMain(dbOP, request, 4);//System.out.println(vRetResult);
	if(vRetResult == null) 
		strErrMsg = cms.getErrMsg();
	else {
		vSYLMain = (Vector)vRetResult.remove(0);
		vChapterSubChapInfo = (Vector)vRetResult.remove(0);
		vRef     = (Vector)vRetResult.remove(0);
	}
}
%>
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
	var childWnd = null;
	function ReloadPage() {
		document.form_.page_action.value = "";
		document.form_.submit();
	}
	function PageAction(strAction) {
		document.form_.page_action.value = strAction;
	}
	function PrintPg() {
		var strPgLoc = "./syllabus_print.jsp?sub_index="+
			document.form_.sub_index[document.form_.sub_index.selectedIndex].value;
		window.open(strPgLoc,"myfile",'dependent=no,width=700,height=500,top=100,left=100,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	}
	function AddFromList(strPageIndex) {
		var strSubIndex = document.form_.sub_index[document.form_.sub_index.selectedIndex].value;
		if(strSubIndex.length == 0) {
			alert("Please select a subject.");
			return;
		}
		var valEntered = "";
		if(strPageIndex == 1) {
			valEntered = document.form_.inst_technique.value;
			if(valEntered.length > 0)
				valEntered = "&inst_detail="+escape(valEntered);
		}
		else if(strPageIndex == 2) {
			valEntered = document.form_.eval_technique.value;
			if(valEntered.length > 0)
				valEntered = "&eval_detail="+escape(valEntered);
		}
		
		var strPgLoc = "";
		if(strPageIndex == 1)
			strPgLoc = "./syl_instructional.jsp?sub_index="+strSubIndex;
		else if(strPageIndex == 2)
			strPgLoc = "./syl_eval.jsp?sub_index="+strSubIndex;
		else if(strPageIndex == 3)
			strPgLoc = "./syl_reference.jsp?sub_index="+strSubIndex;
		else if(strPageIndex == 4) {
			location = "./syl_chapter.jsp?sub_index="+strSubIndex;
			return null;
		}
		strPgLoc = strPgLoc + valEntered;
		
		childWnd = window.open(strPgLoc,"myfile",'dependent=no,width=700,height=500,top=100,left=100,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
		childWnd.focus();
	}
	function  CheckFocus() {
		if(childWnd != null) {
			//alert("Popup is open");
			childWnd.focus();
			return null;
		}
	}
</script>
<body bgcolor="#93B5BB" onFocus="CheckFocus();">
<form name="form_" method="post" action="./syllabus.jsp" onSubmit="SubmitOnceButton(this);">  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#6A99A2"> 
      <td width="100%" height="25" colspan="2" align="center"><font color="#FFFFFF"><strong>:::: SYLLABUS MAINTENANCE PAGE::::</strong></font></td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp;
	  <font size="3" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr> 
      <td height="25" colspan="2"> &nbsp;Subject Code : <font size="1">
<input type="text" name="scroll_sub" size="16" style="font-size:9px" 
	  onKeyUp="AutoScrollListSubject('scroll_sub','sub_index',true,'form_');"
	  class="textbox" onFocus="style.backgroundColor='#D3EBFF'"
	   onBlur="ReloadPage(); style.backgroundColor='#FFFFFF'" > 
(enter subject code to scroll the list)</font>
&nbsp;&nbsp;
<input type="submit" name="13" value="Reload Page" style="font-size:11px; height:28px;border: 1px solid #FF0000;"
	  onClick="PageAction('');"></td>
    </tr>
    <tr> 
      <td height="25" colspan="2">&nbsp;
        <select name="sub_index" title="SELECT A  SUBJECT"
	  	style="font-size:11px;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;" onChange="ReloadPage();">
          <option value=""> .. select a subject .. </option>
		  <%=dbOP.loadCombo("sub_index","sub_code +'&nbsp;&nbsp;&nbsp;('+sub_name+')' as s_code"," from subject where is_del=0 order by s_code",WI.fillTextValue("sub_index"), false)%>
        </select></td>
    </tr>
  </table>

  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="1" cellspacing="0">
<%if(vRetResult != null) {%>
    <tr> 
      <td colspan="4"><div align="right"><a href="javascript:PrintPg();"><img src="../../../images/print.gif"  border="0"></a><font size="1">click 
          to print syllabus</div></td>
    </tr>
<%}%>
    <tr valign="top"> 
      <td colspan="4"><hr size="1" noshade></td>
    </tr>
    <tr valign="top" bgcolor="#EBF5F5"> 
      <td width="22%"><strong>Course Description</strong>: </td>
      <td width="61%" colspan="2" bgcolor="#EBF5F5">
<%
if(vSYLMain != null && vSYLMain.size() > 0) 
	strTemp = (String)vSYLMain.elementAt(0);
else	
	strTemp = WI.fillTextValue("course_desc");
%>
		  <textarea name="course_desc" cols="65" rows="5" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" class="textbox" style="font-size:11px;"><%=WI.getStrValue(strTemp)%></textarea></td>
      <td width="17%">&nbsp;
<%if(vRetResult != null && vRetResult.size() > 0) {%>
	  <input type="submit" name="1" value="Edit" style="font-size:11px; height:28px;border: 1px solid #FF0000;"
	  onClick="PageAction(21);">
<%}%>	  </td>
    </tr>
    <tr valign="top"> 
      <td><strong>Course Objective</strong></td>
      <td colspan="2">
<%
if(vSYLMain != null && vSYLMain.size() > 0) 
	strTemp = (String)vSYLMain.elementAt(1);
else	
	strTemp = WI.fillTextValue("course_obj");
%>	  <textarea name="course_obj" cols="65" rows="5" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" class="textbox" style="font-size:11px;"><%=WI.getStrValue(strTemp)%></textarea></td>
      <td>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
	  <input type="submit" name="1" value="Edit" style="font-size:11px; height:28px;border: 1px solid #FF0000;"
	  onClick="PageAction(22);">
<%}%>	  </td>
    </tr>
    
    
    <tr>
      <td valign="top" bgcolor="#EBF5F5"><strong>Course Outline</strong></td> 
      <td colspan="2" bgcolor="#EBF5F5">
	  <%if(vChapterSubChapInfo != null) {
	    Vector vChapterInfo = (Vector)vChapterSubChapInfo.remove(0);%>
		<table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
			<%for(int i = 0; i < vChapterInfo.size(); i += 6){%>
				<tr valign="top">
					<td class="thinborder">
						<%=vChapterInfo.elementAt(i + 5)%>.<%=vChapterInfo.elementAt(i + 1)%>
					</td>
					<td class="thinborder">
						<%=ConversionTable.replaceString(WI.getStrValue(vChapterInfo.elementAt(i + 2), "&nbsp;"), "\r\n","<br>")%>
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
	  <%}%>
	  
	  </td>
      <td valign="top" bgcolor="#EBF5F5">
	  <%if(vChapterSubChapInfo != null) {%>
	  	<a href="javascript:AddFromList(4);"><img src="../../../images/edit.gif" border="0"></a>
	  <%}else{%>
	  	<font size="1">Save other Information first.</font>
	  <%}%>
	  </td>
    </tr>
    
    <tr valign="top"> 
      <td><strong>Instructional Techniques</strong><br>
      <br>
      <a href="javascript:AddFromList(1);">Add from list</a></td>
      <td colspan="2">
<%
if(vSYLMain != null && vSYLMain.size() > 0) 
	strTemp = (String)vSYLMain.elementAt(2);
else	
	strTemp = WI.fillTextValue("inst_technique");
%>	  <textarea name="inst_technique" cols="65" rows="5" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" class="textbox" style="font-size:11px;" readonly><%=WI.getStrValue(strTemp)%></textarea></td>
      <td>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
	  <input type="submit" name="1" value="Edit" style="font-size:11px; height:28px;border: 1px solid #FF0000;"
	  onClick="PageAction(22);">
<%}%></td>
    </tr>
    <tr bgcolor="#EBF5F5"> 
      <td valign="top"><strong>Evaluation Techniques</strong><br>
        <br>
      <a href="javascript:AddFromList(2);">Add from list</a></td>
      <td colspan="2">
<%
if(vSYLMain != null && vSYLMain.size() > 0) 
	strTemp = (String)vSYLMain.elementAt(3);
else	
	strTemp = WI.fillTextValue("eval_technique");
%>	  <textarea name="eval_technique" cols="65" rows="5" onFocus="style.backgroundColor='#D3EBFF'" 
		onBlur="style.backgroundColor='white'" class="textbox" style="font-size:11px;" readonly><%=WI.getStrValue(strTemp)%></textarea></td>
      <td>
<%if(vRetResult != null && vRetResult.size() > 0) {%>
	  <input type="submit" name="1" value="Edit" style="font-size:11px; height:28px;border: 1px solid #FF0000;"
	  onClick="PageAction(22);">
<%}%></td>
    </tr>
    <tr> 
      <td valign="top"><strong>References</strong></td>
      <td colspan="2">
			<%
			if(vRef != null && vRef.size() > 0) {%>
			  <table width="100%" border="0" bgcolor="#FFFFFF" cellpadding="2" cellspacing="0" class="thinborderALL">
				<tr bgcolor="#BDD5DF">
				  <td height="20" colspan="3" style="font-size:11px" class="thinborderBOTTOM"><div align="center"><strong>LIST OF COURSE
					  REFERENCES</strong></div></td>
				</tr>
			<%for(int i = 0;i < vRef.size();){%>
				<tr>
				  <td width="10%">&nbsp;</td>
				  <td colspan="2"><strong><%=(String)vRef.elementAt(i + 1)%></strong></td>
				</tr>
			<%vRef.setElementAt(null, i + 1);
			for(; i < vRef.size(); i += 5) {
				if(vRef.elementAt( i + 1) != null)
					break;
				%>
				<tr>
				  <td>&nbsp;</td>
				  <td width="5%">&nbsp;</td>
				  <td width="85%"><%=vRef.elementAt( i + 3)%>
				  <font color="#0000FF"><%=WI.getStrValue(ConversionTable.replaceString((String)vRef.elementAt( i + 4),"\n\r","<br>&nbsp;"), "<br>&nbsp;", "", "")%></font></td>
			    </tr>
			<%}//end of for loop - I
			}//end of main for loop.%>	
			  </table>
			<%}%>	  </td>
      <td valign="top">
	  <%if(vRef != null){%>
	  	<a href="javascript:AddFromList(3);"><img src="../../../images/edit.gif" border="0"></a>
	  <%}else{%>
	  	<font size="1">Save other Information first.</font>
	  <%}%>

	  </td>
    </tr>
    <tr> 
      <td colspan="4"><hr size="1" noshade></td>
    </tr>
    <tr> 
      <td colspan="4"><div align="center">
        <input type="submit" name="12" value="<%if(vSYLMain != null){%>Edit<%}else{%>Save<%}%> Information" style="font-size:11px; height:28px;border: 1px solid #FF0000;"
	  onClick="PageAction(1);">
      </div></td>
    </tr>
  </table>

<table width="100%" border="0" cellpadding="2" cellspacing="0">
  <tr bgcolor="#FFFFFF"> 
      <td height="25">&nbsp;</td>
  </tr>
  <tr bgcolor="#6A99A2"> 
    <td height="25">&nbsp;</td>
  </tr>
</table>
<input type="hidden" name="page_action">

<!-- add in pages with subject scroll -->
<%=dbOP.constructAutoScrollHiddenField()%>

</form>
</body>
</html>
<%
dbOP.cleanUP();
%>