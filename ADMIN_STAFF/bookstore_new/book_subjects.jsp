<%@ page language="java" import="utility.*, citbookstore.BookManagement, java.util.Vector"%>
<%
	WebInterface WI = new WebInterface(request);
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
<title>Book-Subject Mapping</title>
<style type="text/css">
.unmapped {
	height:200px; overflow:auto; width:auto; background-color:#A9B9D1;
}
.mapped {
	height:200px; overflow:auto; width:auto; background-color:#A9B9D1;
}
</style>
</head>
<script language="javascript" src="../../jscript/common.js"></script>
<script language="javascript">

	function AddSubjects(){
		document.form_.add_subjects.value = "1";
		document.form_.submit();
	}
	
	function DeleteSubjects(){
		document.form_.delete_subjects.value = "1";
		document.form_.submit();
	}

	function checkAllSaveItems() {
		var maxDisp = document.form_.unmapped_count.value;
		var bolIsSelAll = document.form_.selAllSaveItems.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.save_'+i+'.checked='+bolIsSelAll);
	}
	
	function checkAllDeleteItems() {
		var maxDisp = document.form_.mapped_count.value;
		var bolIsSelAll = document.form_.selAllDeleteItems.checked;
		for(var i =1; i< maxDisp; ++i)
			eval('document.form_.del_'+i+'.checked='+bolIsSelAll);
	}
	
</script>
<%
	DBOperation dbOP = null;
	String strErrMsg = null;
	String strTemp = null;
	
	String strBookIndex = WI.fillTextValue("book_index");
	if(strBookIndex.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Book reference is not found. Please close this window and click update link again from main window.</p>
		<%return;
	}
	
	String strBookCatg = WI.fillTextValue("book_catg");
	if(strBookCatg.length() == 0){%>
		<p style="font-size:16px; color:#FF0000;">Book reference is not found. Please close this window and click update link again from main window.</p>
		<%return;
	}
	
	//add security here
	try{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"BOOKSTORE-BOOK MANAGEMENT","book_subjects.jsp");
	}
	catch(Exception exp){
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
	%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
	<%
		return;
	}
	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE-BOOK MANAGEMENT"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("BOOKSTORE"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("HR MANAGEMENT"),"0"));
		if(iAccessLevel == 0){
			response.sendRedirect("../../commfile/unauthorized_page.jsp");
			return;
		}
	}
	//end of security
	
	int iSearchResultMapped = 0;
	int iSearchResultUnmapped = 0;
	
	BookManagement bm = new BookManagement();
	
	if(WI.fillTextValue("add_subjects").length() > 0){
		if(!bm.saveBookSubjectMapping(dbOP, request))
			strErrMsg = bm.getErrMsg();
		else
			strErrMsg = "Subject(s) successfully mapped to this book.";
	}
	
	if(WI.fillTextValue("delete_subjects").length() > 0){
		if(!bm.deleteBookSubjectMapping(dbOP, request))
			strErrMsg = bm.getErrMsg();
		else
			strErrMsg = "Subject(s) successfully removed from book-subject mapping.";
	}
	
	Vector vSubjects = bm.getUnmappedSubjects(dbOP, request);
	if(vSubjects == null){
		if(WI.fillTextValue("add_subjects").length() == 0)
			strErrMsg = bm.getErrMsg();
	}
	else
		iSearchResultUnmapped = bm.getSearchCount();
		
	Vector vMapped = bm.getMappedSubjects(dbOP, request);
	if(vMapped == null){
		if(WI.fillTextValue("add_subjects").length() == 0)
			strErrMsg = bm.getErrMsg();
	}
	else
		iSearchResultMapped = bm.getSearchCount();
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./book_subjects.jsp" method="post">

	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr bgcolor="#A49A6A"> 
			<td height="25" colspan="3" bgcolor="#A49A6A"><div align="center">
				<font color="#FFFFFF"><strong>:::: BOOK-SUBJECT MAPPING ::::</strong></font></div></td>
		</tr>
		<tr>
			<td height="25" width="3%">&nbsp;</td>
			<td colspan="2"><strong><font size="2" color="#FF0000"><%=WI.getStrValue(strErrMsg)%></font></strong></td>
		</tr>
	</table>

<%if(vSubjects != null && vSubjects.size() > 0){%>
	<div class="unmapped">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right">&nbsp;
				<%if(iAccessLevel > 1){%>
					<a href="javascript:AddSubjects();"><img src="../../images/save.gif" border="0" /></a>
					<font size="1">Click to save book-subject mapping</font>
				<%}%></td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="4" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: SUBJECT LISTING :::</strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOM" colspan="2">
				<strong>Total Results: <%=iSearchResultUnmapped%> - 
					Showing(<strong><%=WI.getStrValue(bm.getDisplayRange(), ""+iSearchResultUnmapped)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="2">&nbsp;
			<%
			if(WI.fillTextValue("view_all").length() == 0){
				int iPageCount = 1;
				iPageCount = iSearchResultUnmapped/bm.defSearchSize;		
				if(iSearchResultUnmapped % bm.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+bm.getDisplayRange()+")";
				
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto_unmapped" onChange="document.form_.submit();">
					<%
						strTemp = WI.fillTextValue("jumpto_unmapped");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						int i = Integer.parseInt(strTemp);
						if(i > iPageCount)
							strTemp = Integer.toString(--i);
			
						for(i =1; i<= iPageCount; ++i ){
							if(i == Integer.parseInt(strTemp) ){%>
								<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}else{%>
								<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}
						}%>
					</select></div>
				<%}}%></td>
		</tr>
    	<tr>
			<td width="5%"  align="center" height="23" class="thinborder"><strong>Count</strong></td>
			<td width="60%" align="center" class="thinborder"><strong>Subject Name </strong></td>
			<td width="25%" align="center" class="thinborder"><strong>Subject Code </strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Select<br />All<br /></strong>
				<input type="checkbox" name="selAllSaveItems" value="0" onClick="checkAllSaveItems();"></td>
    	</tr>
		<% 
			int iResultCount = (Integer.parseInt(WI.getStrValue(WI.fillTextValue("jumpto_unmapped"), "1")) - 1) * bm.defSearchSize + 1;
			int iCount = 1;
	   		for (int i = 0; i < vSubjects.size(); i+=3,iCount++,iResultCount++){
		%>
		<tr>
      		<td height="25" class="thinborder"><div align="center"><%=iResultCount%></div></td>
      		<td class="thinborder">&nbsp;<%=(String)vSubjects.elementAt(i+1)%></td>
      		<td class="thinborder">&nbsp;<%=(String)vSubjects.elementAt(i+2)%></td>
      		<td align="center" class="thinborder">        
				<input type="checkbox" name="save_<%=iCount%>" value="<%=(String)vSubjects.elementAt(i)%>" tabindex="-1"></td>
    	</tr>
    	<%} //end for loop%>
		<input type="hidden" name="unmapped_count" value="<%=iCount%>">
		<tr>
			<td height="25" colspan="4" align="center">
			<%if(iAccessLevel > 1){%>
				<a href="javascript:AddSubjects();"><img src="../../images/save.gif" border="0" /></a>
				<font size="1">Click to save book-subject mapping</font>
			<%}else{%>
				Not authorized to save book-subject mapping.
			<%}%></td>
		</tr>
		<tr>
			<td height="20" colspan="4">&nbsp;</td>
		</tr>
	</table>
	</div>
<%}%>
	
	<table width="100%" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" border="0">
		<tr>
			<td height="15">&nbsp;</td>
		</tr>
	</table>
	
<%if(vMapped != null && vMapped.size() > 0){%>
	<div class="mapped">
	<table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
		<tr>
			<td height="25" align="right">&nbsp;
				<%if(iAccessLevel > 1){%>
					<a href="javascript:DeleteSubjects();"><img src="../../images/delete.gif" border="0" /></a>
					<font size="1">Click to delete from book-subject mapping.</font>
				<%}%></td>
		</tr>
	</table>
	<table width="100%" border="0" cellpadding="0" cellspacing="0"  bgcolor="#FFFFFF" class="thinborder">
		<tr> 
		  	<td height="20" colspan="7" bgcolor="#B9B292" class="thinborder">
				<div align="center"><strong>::: MAPPED SUBJECTS LISTING ::: </strong></div></td>
		</tr>
		<tr> 
			<td class="thinborderBOTTOM" colspan="2">
				<strong>Total Results: <%=iSearchResultMapped%> - 
					Showing(<strong><%=WI.getStrValue(bm.getDisplayRange(), ""+iSearchResultMapped)%></strong>)</strong></td>
			<td class="thinborderBOTTOM" height="25" colspan="2">&nbsp;
			<%
			if(WI.fillTextValue("view_all").length() == 0){
				int iPageCount = 1;
				iPageCount = iSearchResultMapped/bm.defSearchSize;		
				if(iSearchResultMapped % bm.defSearchSize > 0)
					++iPageCount;
				strTemp = " - Showing("+bm.getDisplayRange()+")";
				
				if(iPageCount > 1){%> 
					<div align="right">Jump To page: 
					<select name="jumpto_mapped" onChange="document.form_.submit();">
					<%
						strTemp = WI.fillTextValue("jumpto_mapped");
						if(strTemp == null || strTemp.trim().length() ==0)
							strTemp = "0";
						int i = Integer.parseInt(strTemp);
						if(i > iPageCount)
							strTemp = Integer.toString(--i);
			
						for(i =1; i<= iPageCount; ++i ){
							if(i == Integer.parseInt(strTemp) ){%>
								<option selected value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}else{%>
								<option value="<%=i%>"><%=i%> of <%=iPageCount%></option>
							<%}
						}%>
					</select></div>
				<%}}%></td>
		</tr>
    	<tr>
			<td width="5%"  align="center" height="23" class="thinborder"><strong>Count</strong></td>
			<td width="60%" align="center" class="thinborder"><strong>Subject Name </strong></td>
			<td width="25%" align="center" class="thinborder"><strong>Subject Code </strong></td>
			<td width="10%" align="center" class="thinborder"><strong>Select<br />All<br /></strong>
				<input type="checkbox" name="selAllDeleteItems" value="0" onClick="checkAllDeleteItems();"></td>
    	</tr>
		<% 
			int iResultCount = (Integer.parseInt(WI.getStrValue(WI.fillTextValue("jumpto_mapped"), "1")) - 1) * bm.defSearchSize + 1;
			int iCount = 1;
	   		for (int i = 0; i < vMapped.size(); i+=3,iCount++,iResultCount++){
		%>
		<tr>
      		<td height="25" class="thinborder"><div align="center"><%=iResultCount%></div></td>
      		<td class="thinborder"><%=(String)vMapped.elementAt(i+1)%></td>
      		<td class="thinborder"><%=(String)vMapped.elementAt(i+2)%></td>
      		<td align="center" class="thinborder">        
				<input type="checkbox" name="del_<%=iCount%>" value="<%=(String)vMapped.elementAt(i)%>" tabindex="-1"></td>
    	</tr>
    	<%} //end for loop%>
		<input type="hidden" name="mapped_count" value="<%=iCount%>">
		<tr>
			<td height="25" colspan="4" align="center">
			<%if(iAccessLevel > 1){%>
				<a href="javascript:DeleteSubjects();"><img src="../../images/delete.gif" border="0" /></a>
				<font size="1">Click to delete from book-subject mapping.</font>
			<%}else{%>
				Not authorized to delete subject from mapping.
			<%}%></td>
		</tr>
		<tr>
			<td height="20" colspan="4">&nbsp;</td>
		</tr>
	</table>
	</div>
<%}%>
	
	<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr> 
			<td height="25" colspan="3">&nbsp;</td>
		</tr>
		<tr>
			<td height="25" colspan="3" bgcolor="#A49A6A">&nbsp;</td>
		</tr>
	</table>
	
	<input type="hidden" name="add_subjects" />
	<input type="hidden" name="delete_subjects" />
	<input type="hidden" name="book_index" value="<%=strBookIndex%>" />
	<input type="hidden" name="book_catg" value="<%=strBookCatg%>" />
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>